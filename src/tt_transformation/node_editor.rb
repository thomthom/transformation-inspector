module TT::Plugins::TransformationInspector
class NodeEditor

  attr_reader :nodes

  def initialize
    # @type [Array<Node>]
    @nodes = []

    # @type [UI::HtmlDialog]
    @dialog = nil

    @updating = false

    # DEBUG
    @nodes = create_dummy_nodes
  end

  def show
    show_node_editor
  end

  def close
    @dialog.close
  end

  private

  NAMESPACE = TT::Plugins::TransformationInspector

  def updating?
    @updating
  end

  # @return [UI::HtmlDialog]
  def create_node_editor
    options = {
      dialog_title: "Transformation Node Editor",
      preferences_key: "#{EXTENSION[:product_id]}_node_editor",
      scrollable: false,
      resizable: true,
      width: 600,
      height: 400,
      left: 100,
      top: 100,
      min_width: 200,
      min_height: 200,
      style: UI::HtmlDialog::STYLE_DIALOG
    }
    dialog = UI::HtmlDialog.new(options)
    path = File.join(PATH, 'ui', 'nodes.html')
    dialog.set_file(path)
    dialog
  end

  # @param [UI::HtmlDialog] dialog
  def add_callbacks(dialog)
    dialog.add_action_callback('ready') do |ctx|
      ready(dialog)
    end
    dialog.add_action_callback('connect') do |ctx, input_id, output_id|
      connect(dialog, input_id, output_id)
    end
    dialog.add_action_callback('disconnect') do |ctx, input_id, output_id|
      disconnect(dialog, input_id, output_id)
    end
    dialog.add_action_callback('sync_position') do |ctx, node_id, position|
      sync_position(dialog, node_id, Geom::Point2d.new(*position))
    end
    dialog.add_action_callback('sync_transformation') do |ctx, node_id, transformation|
      sync_transformation(dialog, node_id, transformation)
    end
    dialog.add_action_callback('sync_draw_mode') do |ctx, node_id, mode|
      sync_draw_mode(dialog, node_id, mode)
    end
    dialog.add_action_callback('sync_line_stipple') do |ctx, node_id, stipple|
      sync_line_stipple(dialog, node_id, stipple)
    end
    dialog.add_action_callback('new_node') do |ctx, node_type|
      new_node(dialog, node_type)
    end
    dialog.set_on_closed do
      deactivate_canvas
    end
  end

  def show_node_editor
    # @dialog ||= create_node_editor
    @dialog = create_node_editor
    if @dialog.visible?
      @dialog.bring_to_front
    else
      add_callbacks(@dialog)
      activate_canvas
      @dialog.show
    end
    nil
  end

  def activate_canvas
    model = Sketchup.active_model
    canvas = Canvas.new(self)
    model.select_tool(canvas)
    nil
  end

  def deactivate_canvas
    model = Sketchup.active_model
    model.select_tool(nil)
    nil
  end

  # @param [UI::HtmlDialog] dialog
  def ready(dialog)
    puts "Ready"
    update_node_types(dialog)
    update(dialog)
  end

  def update(dialog)
    nodes_data = @nodes.map(&:to_h)
    nodes_json = JSON.pretty_generate(nodes_data)
    @updating = true
    dialog.execute_script("updateNodes(#{nodes_json})")
    @updating = false
  end

  def update_node_types(dialog)
    names = NAMESPACE.constants.grep(/\w+Node$/)
    klasses = names.map { |name| NAMESPACE.const_get(name) }
    # labels = klasses.map { |klass| class.name[0,-4] }
    types = []
    klasses.each { |klass|
      types << { id: klass.typename, label: klass.typename[0...-4] }
    }
    types.sort! { |a, b| a[:label] <=> b[:label] }
    types_json = JSON.pretty_generate(types)
    dialog.execute_script("updateNodeTypes(#{types_json})")
  end

  # @param [UI::HtmlDialog] dialog
  # @param [Integer] node_id
  # @param [Geom::Point2d] position
  def sync_position(dialog, node_id, position)
    return if updating?
    puts "sync_position #{node_id}: #{position.inspect}"
    # @type [Node]
    node = object_from_id(Node, node_id)
    node.position = position
  end

  def sync_transformation(dialog, node_id, transformation)
    return if updating?
    puts "sync_transformation #{node_id}: #{transformation.inspect}"
    # @type [TransformationNode]
    node = object_from_id(TransformationNode, node_id)
    tr = Geom::Transformation.new(transformation)
    node.set_config(:transformation, tr)
    # TODO: trigger output update
    Sketchup.active_model.active_view.invalidate
  end

  def sync_draw_mode(dialog, node_id, mode)
    return if updating?
    puts "sync_draw_mode #{node_id}: #{mode.inspect}"
    # @type [DrawPointsNode]
    node = object_from_id(DrawPointsNode, node_id)
    node.set_config(:mode, mode)
    Sketchup.active_model.active_view.invalidate
  end

  def sync_line_stipple(dialog, node_id, stipple)
    return if updating?
    puts "sync_line_stipple #{node_id}: #{stipple.inspect}"
    # @type [DrawPointsNode]
    node = object_from_id(DrawPointsNode, node_id)
    node.set_config(:stipple, stipple)
    Sketchup.active_model.active_view.invalidate
  end

  # @param [UI::HtmlDialog] dialog
  def connect(dialog, input_id, output_id)
    puts "Connect #{input_id} to #{output_id}"
    # @type [Node::InputConnectionPoint]
    input = object_from_id(Node::InputConnectionPoint, input_id)
    # @type [Node::OutputConnectionPoint]
    output = object_from_id(Node::OutputConnectionPoint, output_id)
    p input
    p output
    input.connect_to(output)
    update(dialog) # TODO: Use notifications
    # update(dialog) do
    #   # Use notifications to collect changed nodes and propagate updates
    #   # for only those to the webdialog.
    #   input.connect_to(output)
    # end
  end

  # @param [UI::HtmlDialog] dialog
  def disconnect(dialog, input_id, output_id)
    puts "Disconnect #{input_id} to #{output_id}"
    # @type [Node::InputConnectionPoint]
    input = object_from_id(Node::InputConnectionPoint, input_id)
    # @type [Node::OutputConnectionPoint]
    output = object_from_id(Node::OutputConnectionPoint, output_id)
    p input
    p output
    input.disconnect_from(output)
    update(dialog) # TODO: Use notifications
  end

  # @param [UI::HtmlDialog] dialog
  # @param [String] node_type
  def new_node(dialog, node_type)
    # TODO: move nodes to Nodes namespace
    # node_class = Nodes.const_get(node_type)
    node_class = NAMESPACE.const_get(node_type)
    node = node_class.new
    @nodes << node
    update(dialog)
  end

  # @param [Class] klass
  # @param [Integer] id
  def object_from_id(klass, id)
    raise TypeError "id was not an integer" unless id.kind_of?(Integer)
    value = ObjectSpace._id2ref(id)
    # ObjectSpace._id2ref(880)
    # Error: #<RangeError: "880" is recycled object>
    unless value.kind_of?(klass)
      raise TypeError "object was of type #{value.class}, expected #{klass}"
    end
    value
  end

  def create_dummy_nodes
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 9, 0),
      Geom::Point3d.new(0, 9, 0),
    ]
    points_node = PointsNode.new(points: points)
    points_node.position = Geom::Point2d.new(100, 0)

    tr1 = Geom::Transformation.scaling(1,2,3)
    tr_node1 = TransformationNode.new(transformation: tr1)
    tr_node1.position = Geom::Point2d.new(300, 0)
    tr_node1.input(:geom).connect_to(points_node.output(:geom))

    tr2 = Geom::Transformation.new(ORIGIN, Y_AXIS)
    tr_node2 = TransformationNode.new(transformation: tr2)
    tr_node2.position = Geom::Point2d.new(600, 0)
    tr_node2.input(:geom).connect_to(tr_node1.output(:geom))

    tr3 = Geom::Transformation.new(Geom::Point3d.new(10, 20, 30))
    tr_node3 = TransformationNode.new(transformation: tr3)
    tr_node3.position = Geom::Point2d.new(300, 300)

    draw_node = DrawPointsNode.new
    draw_node.position = Geom::Point2d.new(850, 0)
    draw_node.input(:geom).connect_to(tr_node2.output(:geom))

    [points_node, tr_node1, tr_node2, tr_node3, draw_node]
  end


  class Canvas

    # @param [NodeEditor] editor
    def initialize(editor)
      @editor = editor
    end

    def activate
      view = Sketchup.active_model.active_view
      view.invalidate
    end

    # @param [Sketchup::View] view
    def deactivate(view)
      view.invalidate
    end

    # @param [Sketchup::View] view
    def suspend(view)
      view.invalidate
    end

    # @param [Sketchup::View] view
    def resume(view)
      view.invalidate
    end

    # @param [Sketchup::View] view
    def draw(view)
      @editor.nodes.each { |node|
        next unless node.respond_to?(:draw)

        node.draw(view)
      }
    end

  end

end # class
end # module
