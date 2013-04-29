#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
begin
  require 'TT_Lib2/core.rb'
rescue LoadError => e
  module TT
    if @lib2_update.nil?
      url = 'http://www.thomthom.net/software/sketchup/tt_lib2/errors/not-installed'
      options = {
        :dialog_title => 'TT_Lib² Not Installed',
        :scrollable => false, :resizable => false, :left => 200, :top => 200
      }
      w = UI::WebDialog.new( options )
      w.set_size( 500, 300 )
      w.set_url( "#{url}?plugin=#{File.basename( __FILE__ )}" )
      w.show
      @lib2_update = w
    end
  end
end


#-------------------------------------------------------------------------------

if defined?( TT::Lib ) && TT::Lib.compatible?( '2.7.0', 'Transformation Inspector' )

module TT::Plugins::TransformationInspector

  ### MENU & TOOLBARS ### ------------------------------------------------------
  
  unless file_loaded?( __FILE__ )
    m = TT.menu( 'Plugins' )
    m.add_item( 'Transformation Inspector' ) { self.inspect_transformation }
  end 
  
  
  ### MAIN SCRIPT ### ----------------------------------------------------------
  
  # @since 1.0.0
  def self.inspect_transformation
    width  = 400
    height = 730
    
    options = {
      :dialog_title => 'Transformation Matrix',
      :scrollable   => false,
      :pref_key     => PLUGIN_ID,
      :resizable    => false,
      :left         => 200,
      :top          => 200,
      :width        => width,
      :height       => height
    }
    
    @window = self.create_window( options )
    
    # Display the window on top of SketchUp's window.
    if @window.visible?
      @window.bring_to_front
    else
      if TT::System::PLATFORM_IS_OSX
        @window.show_modal
      else
        @window.show
      end
    end
  end
  
  # @param [Hash] options
  #
  # @return [UI::WebDialog]
  # @since 1.0.0
  def self.create_window( options )
    html_file = File.join( PATH, 'matrix.html' )
    
    width  = options[ :width ]
    height = options[ :height ]
    
    window = UI::WebDialog.new( options )
    window.navigation_buttons_enabled = false
    window.set_size( width, height )
    
    window.add_action_callback( 'update_transformation' ) { |dialog, params|
      #puts "update_transformation()"
      #puts "update_transformation( #{params.inspect} )"
      arg1, arg2 = params.split('||')
      matrix = Geom::Transformation.new( eval( arg1 ) )
      transformation = Geom::Transformation.new( eval( arg2 ) )
      
      result = matrix * transformation
      
      model = Sketchup.active_model
      sel = model.selection
      if sel.length == 1 && TT::Instance.is?( sel[0] )
        instance = sel[0]
        instance.transformation = result
      end
      
      script = "UI.update_result_matrix(#{result.to_a.inspect});"
      @window.execute_script( script )
    }
    
    window.add_action_callback( 'Window_Ready' ) { |dialog, params|
      #puts "Window_Ready()"
      self.selection_changed( Sketchup.active_model.selection )
      self.observe_models
    }
    
    window.set_on_close {
      #puts 'Window Closing...'
      # Detach observers.
      if @app_observer
        Sketchup.remove_observer( @app_observer )
      end
      if @selection_observer
        Sketchup.active_model.selection.remove_observer( @selection_observer )
      end
    }
    
    window.set_file( html_file )
    window
  end
  
  
  # @param [Sketchup::Selection] selection
  #
  # @since 1.0.0
  def self.selection_changed( selection )
    #puts "Selection Changed (#{selection.length})"
    if @window && @window.visible?
      if selection.length == 1 && TT::Instance.is?( selection[0] )
        instance = selection[0]
        definition = TT::Instance.definition( instance )
        #puts "> Selected: #{instance.typename} (#{instance.name}) <#{definition.name}>"
        k = instance.typename
        n = "#{instance.name} (#{definition.name})"
        m = instance.transformation.to_a
        script = "UI.update_entity(#{k.inspect},#{n.inspect},#{m.inspect});"
        @window.execute_script( script )
      else
        #puts '> Invalid Selection'
        @window.execute_script( "UI.reset();" )
      end
    end
  end
  
  
  # @param [Sketchup::Model] model
  #
  # @since 1.0.0
  def self.observe_selection( model )
    #puts '> Attaching Selection Observer'
    @selection_observer ||= SelectionObserver.new { |selection|
      self.selection_changed( selection )
    }
    model.selection.remove_observer( @selection_observer ) if @selection_observer
    model.selection.add_observer( @selection_observer )
  end
  
  
  # @since 1.0.0
  def self.observe_models
    #puts 'Observing current model'
    @app_observer ||= AppObserver.new
    Sketchup.remove_observer( @app_observer ) if @app_observer
    Sketchup.add_observer( @app_observer )
    self.observe_selection( Sketchup.active_model )
    #puts '---'
  end
  
  
  # @since 1.0.0
  class SelectionObserver < Sketchup::SelectionObserver
    
    # @since 1.0.0
    def initialize( &block )
      @proc = block
    end
    
    # @since 1.0.0
    def onSelectionBulkChange( selection )
      selectionChanged( selection )
    end
    
    # @since 1.0.0
    def onSelectionCleared( selection )
      selectionChanged( selection )
    end
    
    # @param [Sketchup::Selection] selection
    #
    # @since 1.0.0
    def selectionChanged( selection )
      #puts "\n[Event] Selection Changed (#{Time.now.to_i})"
      @proc.call( selection )
    end
    
  end # class SelectionObserver
  
  
  # @since 1.0.0
  class AppObserver < Sketchup::AppObserver
    
    # @since 1.0.0
    def onNewModel( model )
      #puts 'onNewModel'
      TT::Plugins::TransformationInspector.observe_selection( model )
    end
    
    # @since 1.0.0
    def onOpenModel( model )
      #puts 'onOpenModel'
      TT::Plugins::TransformationInspector.observe_selection( model )
    end
    
  end # class AppObserver


  
  ### DEBUG ### ------------------------------------------------------------  
  
  # @note Debug method to reload the plugin.
  #
  # @example
  #   TT::Plugins::TransformationInspector.reload
  #
  # @param [Boolean] tt_lib Reloads TT_Lib2 if +true+.
  #
  # @return [Integer] Number of files reloaded.
  # @since 1.0.0
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    TT::Lib.reload if tt_lib
    # Core file (this)
    load __FILE__
    # Supporting files
    if defined?( PATH ) && File.exist?( PATH )
      x = Dir.glob( File.join(PATH, '*.{rb,rbs}') ).each { |file|
        load file
      }
      x.length + 1
    else
      1
    end
  ensure
    $VERBOSE = original_verbose
  end
  
end # module

end # if TT_Lib

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------