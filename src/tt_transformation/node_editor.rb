module TT::Plugins::TransformationInspector
class NodeEditor

  def initialize
    # @type [Array<Node>]
    @nodes = []

    # @type [UI::HtmlDialog]
    @dialog = nil

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
  end

  def show_node_editor
    # @dialog ||= create_node_editor
    @dialog = create_node_editor
    if @dialog.visible?
      @dialog.bring_to_front
    else
      add_callbacks(@dialog)
      @dialog.show
    end
    nil
  end

  # @param [UI::HtmlDialog] dialog
  def ready(dialog)
    puts "Ready"
    update(dialog)
  end

  def update(dialog)
    nodes_data = @nodes.map(&:to_h)
    nodes_json = JSON.pretty_generate(nodes_data)
    dialog.execute_script("updateNodes(#{nodes_json})")
  end

  # @param [UI::HtmlDialog] dialog
  def connect(dialog, input_id, output_id)
    puts "Connect #{input_id} to #{output_id}"
    # @type [Node::InputConnectionPoint]
    input = ObjectSpace._id2ref(input_id)
    # @type [Node::OutputConnectionPoint]
    output = ObjectSpace._id2ref(output_id)
    # TODO: Handle possible error?
    # ObjectSpace._id2ref(880)
    # Error: #<RangeError: "880" is recycled object>
    p input
    p output
    input.connect_to(output)
    update(dialog) # TODO: Use notifications
  end

  # @param [UI::HtmlDialog] dialog
  def disconnect(dialog, input_id, output_id)
    puts "Disconnect #{input_id} to #{output_id}"
    # @type [Node::InputConnectionPoint]
    input = ObjectSpace._id2ref(input_id)
    # @type [Node::OutputConnectionPoint]
    output = ObjectSpace._id2ref(output_id)
    p input
    p output
    # input.disconnect_from(output) # TODO:
    # update(dialog) # TODO: Use notifications
  end

  def create_dummy_nodes
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 9, 0),
      Geom::Point3d.new(0, 9, 0),
    ]
    points_node = PointsNode.new(points: points)

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

    [points_node, tr_node1, tr_node2, tr_node3]
  end

end # class
end # module
