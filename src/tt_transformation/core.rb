require 'tt_transformation/vendor/transformation'
require 'tt_transformation/instance'

module TT::Plugins::TransformationInspector

  unless file_loaded?( __FILE__ )
    menu = UI.menu( 'Plugins' )
    menu.add_item( 'Transformation Inspector' ) { self.inspect_transformation }
    file_loaded( __FILE__ )
  end


  def self.inspect_transformation
    width  = 400
    height = 970

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
      if Sketchup.platform == :platform_osx
        @window.show_modal
      else
        @window.show
      end
    end
  end

  # @param [Hash] options
  #
  # @return [UI::WebDialog]
  def self.create_window( options )
    html_file = File.join( PATH_UI, 'matrix.html' )

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
      if sel.length == 1 && Instance.is?( sel[0] )
        instance = sel[0]
        instance.transformation = result
      end

      d = self.decompose_matrix(result)
      script = "UI.update_result_matrix(#{result.to_a.inspect}, #{d.to_json});"
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

  # @param [Geom::Transformation]
  # @return [Hash]
  def self.decompose_matrix(transformation)
    {
      rotation: self.euler_angles(transformation).map(&:radians),
      scale: self.scaling(transformation),
    }
  end

  def self.euler_angles(transformation)
    LGeom::LTransformation.euler_angles(transformation)
  rescue StandardError => error
    puts error
    [0.0, 0.0, 0.0]
  end

  def self.scaling(transformation)
    [
      LGeom::LTransformation.xscale(transformation),
      LGeom::LTransformation.yscale(transformation),
      LGeom::LTransformation.zscale(transformation),
    ]
  rescue StandardError => error
    puts error
    [0.0, 0.0, 0.0]
  end


  # @param [Sketchup::Selection] selection
  def self.selection_changed( selection )
    #puts "Selection Changed (#{selection.length})"
    if @window && @window.visible?
      if selection.length == 1 && Instance.is?( selection[0] )
        instance = selection[0]
        definition = Instance.definition( instance )
        #puts "> Selected: #{instance.typename} (#{instance.name}) <#{definition.name}>"
        tr = instance.model.edit_transform
        local_transform = instance.transformation * tr.inverse
        k = instance.typename
        n = "#{instance.name} (#{definition.name})"
        m = local_transform.to_a
        d = self.decompose_matrix(local_transform)
        script = "UI.update_entity(#{k.inspect},#{n.inspect},#{m.inspect},#{d.to_json});"
        @window.execute_script( script )
      else
        #puts '> Invalid Selection'
        @window.execute_script( "UI.reset();" )
      end
    end
  end


  # @param [Sketchup::Model] model
  def self.observe_selection( model )
    #puts '> Attaching Selection Observer'
    @selection_observer ||= SelectionObserver.new { |selection|
      self.selection_changed( selection )
    }
    model.selection.remove_observer( @selection_observer ) if @selection_observer
    model.selection.add_observer( @selection_observer )
  end


  def self.observe_models
    #puts 'Observing current model'
    @app_observer ||= AppObserver.new
    Sketchup.remove_observer( @app_observer ) if @app_observer
    Sketchup.add_observer( @app_observer )
    self.observe_selection( Sketchup.active_model )
    #puts '---'
  end


  class SelectionObserver < Sketchup::SelectionObserver

    def initialize( &block )
      @proc = block
    end

    def onSelectionBulkChange( selection )
      selectionChanged( selection )
    end

    def onSelectionCleared( selection )
      selectionChanged( selection )
    end

    # @param [Sketchup::Selection] selection
    #
    def selectionChanged( selection )
      #puts "\n[Event] Selection Changed (#{Time.now.to_i})"
      @proc.call( selection )
    end

  end # class SelectionObserver


  class AppObserver < Sketchup::AppObserver

    def onNewModel( model )
      #puts 'onNewModel'
      TT::Plugins::TransformationInspector.observe_selection( model )
    end

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
  # @return [Integer] Number of files reloaded.
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    load __FILE__
    if defined?( PATH ) && File.exist?( PATH )
      x = Dir.glob( File.join(PATH, '*.rb') ).each { |file|
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
