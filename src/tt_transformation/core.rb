
require 'tt_transformation/nodes/example'
require 'tt_transformation/node_editor'

require 'tt_transformation/transformation_helper'
require 'tt_transformation/instance'

require 'json'

module TT::Plugins::TransformationInspector

  unless file_loaded?(__FILE__)
    images_path = File.join(PATH, 'images')
    ext = Sketchup.platform == :platform_win ? 'svg' : 'pdf'

    cmd = UI::Command.new('Transformation Inspector') do
      self.inspect_transformation
    end
    cmd.large_icon = File.join(images_path, "inspector.#{ext}")
    cmd.small_icon = cmd.large_icon
    cmd_inspector = cmd

    menu_name = Sketchup.version.to_f < 21.1 ? 'Plugins' : 'Developer'
    menu = UI.menu(menu_name)
    menu.add_item(cmd_inspector)
    menu.add_item('Node Editor') { self.show_node_editor }

    if Sketchup.version.to_i >= 16
      toolbar = UI::Toolbar.new('Transformation Inspector')
      toolbar.add_item(cmd_inspector)
      toolbar.restore
    end

    file_loaded(__FILE__)
  end

  MATRIX_WIDTH = 400
  MATRIX_COLLAPSED_HEIGHT = 470
  MATRIX_EXPANDED_HEIGHT = 1000

  # TT::Plugins::TransformationInspector.node_editor
  def self.node_editor
    @node_editor
  end

  def self.show_node_editor
    @node_editor ||= NodeEditor.new
    @node_editor.show
    nil
  end


  def self.inspect_transformation
    width  = MATRIX_WIDTH
    height = MATRIX_COLLAPSED_HEIGHT

    options = {
      :dialog_title => 'Transformation Matrix',
      :scrollable   => false,
      :pref_key     => EXTENSION[:product_id],
      :resizable    => false,
      :left         => 200,
      :top          => 200,
      :width        => width,
      :height       => height
    }

    @collapsed = true
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
    html_file = File.join(PATH, 'ui', 'matrix.html')

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
      result.extend(TransformationHelper)

      model = Sketchup.active_model
      sel = model.selection
      if sel.length == 1 && Instance.is?( sel[0] )
        instance = sel[0]
        instance.transformation = result
      end

      d = result.decompose_matrix
      script = "UI.update_result_matrix(#{result.to_a.inspect}, #{d.to_json});"
      @window.execute_script( script )
    }

    window.add_action_callback( 'Window_Ready' ) { |dialog, params|
      #puts "Window_Ready()"
      self.selection_changed( Sketchup.active_model.selection )
      self.observe_models
    }

    window.add_action_callback('toggle_more') { |dialog, params|
      # puts "toggle_more"
      @collapsed = !@collapsed
      height = @collapsed ? MATRIX_COLLAPSED_HEIGHT : MATRIX_EXPANDED_HEIGHT
      dialog.set_size(MATRIX_WIDTH, height)
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
  def self.selection_changed( selection )
    #puts "Selection Changed (#{selection.length})"
    if @window && @window.visible?
      if selection.length == 1 && Instance.is?( selection[0] )
        instance = selection[0]
        definition = Instance.definition( instance )
        #puts "> Selected: #{instance.typename} (#{instance.name}) <#{definition.name}>"
        tr = instance.model.edit_transform
        local_transform = instance.transformation * tr.inverse
        local_transform.extend(TransformationHelper)
        k = instance.typename # rubocop:disable SketchupPerformance/Typename
        n = "#{instance.name} (#{definition.name})"
        m = local_transform.to_a
        d = local_transform.decompose_matrix
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
  def self.reload
    original_verbose = $VERBOSE
    $VERBOSE = nil
    @node_editor&.close
    @node_editor = nil
    @window&.close
    @window = nil
    # rubocop:disable SketchupSuggestions/FileEncoding
    load __FILE__
    pattern = File.join(__dir__, '**/*.rb')
    # rubocop:enable SketchupSuggestions/FileEncoding
    Dir.glob(pattern).each { |file| load file }.size
  ensure
    $VERBOSE = original_verbose
  end

end # module
