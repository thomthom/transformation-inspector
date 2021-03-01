require 'fileutils'
require 'json'

require 'tt_transformation/nodes/notification_manager'

require 'tt_transformation/nodes/draw_points'
require 'tt_transformation/nodes/node'
require 'tt_transformation/nodes/points'
require 'tt_transformation/nodes/transform'
require 'tt_transformation/nodes/transformation'
require 'tt_transformation/nodes/view_transformation'

module TT::Plugins::TransformationInspector
class NodeEditor

  SESSION_FILE_EXTENSION = '.nodes.json'.freeze

  attr_reader :nodes

  def initialize
    # @type [Array<Node>]
    @nodes = []

    # @type [UI::HtmlDialog]
    @dialog = nil

    @updating = false
  end

  def show
    restore_session
    show_node_editor
  end

  def close
    @dialog&.close
  end

  def on_update_config(event_data)
    puts "on_update_config(#{event_data})"
    node = event_data[:node]
    data = node.to_h
    json = JSON.pretty_generate(data)
    @dialog.execute_script("updateNodeConfig(#{json})")
    nil
  end

  private

  def updating?
    @updating
  end

  # @return [UI::HtmlDialog]
  def create_node_editor
    puts "create_node_editor"
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
    NotificationManager.default.reset
    NotificationManager.default.add_listener(self)
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
    dialog.add_action_callback('sync_draw_config') do |ctx, node_id, key, value|
      sync_draw_config(dialog, node_id, key.to_sym, value)
    end
    dialog.add_action_callback('new_node') do |ctx, node_type|
      new_node(dialog, node_type)
    end
    dialog.add_action_callback('remove_node') do |ctx, node_id|
      remove_node(dialog, node_id)
    end
    dialog.add_action_callback('save_session') do |ctx|
      save_session(dialog)
    end
    dialog.add_action_callback('load_session') do |ctx|
      load_session(dialog)
    end
    dialog.add_action_callback('reset_session') do |ctx|
      reset_session(dialog)
    end
    dialog.set_on_closed do
      end_session
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

  def restore_session
    return unless @nodes.empty?

    if File.exists?(last_session_path)
      puts "restoring session..."
      begin
        @nodes = read(last_session_path)
        return
      rescue => error
        puts "> failed to restore session, falling back to default..."
        # @nodes = create_default_nodes
        # raise
        p error
        puts error.backtrace.join("\n")
        UI.beep
      end
    end

    puts "creating default nodes..."
    @nodes = create_default_nodes
    nil
  end

  def end_session
    deactivate_canvas
    unless File.directory?(app_data_path)
      FileUtils.mkdir_p(app_data_path)
    end
    write(last_session_path, @nodes)
    puts "saved session to #{last_session_path}"
    nil
  end

  def clear_last_session
    if File.exists?(last_session_path)
      File.delete(last_session_path)
    end
    nil
  end

  # @return [String]
  def app_data_path
    if Sketchup.platform == :platform_win
      app_path = File.expand_path(ENV['APPDATA'])
      path = File.join(app_path, 'Transformation Inspector')
    else
      raise NotImplementedError, "Platform #{Sketchup.platform} not supported"
    end
  end

  # @return [String]
  def last_session_path
    File.join(app_data_path, 'last_session.json')
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
    names = Nodes.constants.grep(/\w+Node$/)
    klasses = names.map { |name| Nodes.const_get(name) }
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

  # @param [UI::HtmlDialog] dialog
  # @param [Integer] node_id
  # @param [Symbol] key
  # @param [Object] value
  def sync_draw_config(dialog, node_id, key, value)
    return if updating?
    puts "sync_draw_config(#{key}, node: #{node_id}, value: #{value.inspect})"
    # @type [DrawPointsNode]
    node = object_from_id(DrawPointsNode, node_id)
    node.set_config(key, value)
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
    node_class = Nodes.const_get(node_type)
    node = node_class.new
    @nodes << node
    update(dialog)
  end

  # @param [UI::HtmlDialog] dialog
  # @param [Integer] node_id
  def remove_node(dialog, node_id)
    node = object_from_id(Node, node_id)
    node.class.input_channels.each { |symbol, channel|
      input = node.input(channel.id)
      input.disconnect_from(input.partner) if input.partner
    }
    node.class.output_channels.each { |symbol, channel|
      output = node.output(channel.id)
      output.partners.each { |partner|
        output.disconnect_from(partner) if partner
      }
    }
    @nodes.delete(node)
    update(dialog) # TODO: Use notifications
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

  # @param [String] path
  # @return [Array<Node>]
  def read(path)
    json = File.read(path, encoding: 'utf-8')
    data = JSON.parse(json, symbolize_names: true)
    deserialize_nodes(data)
  end

  # @param [String] path
  # @param [Array<Node>] nodes
  def write(path, nodes)
    data = serialize_nodes(nodes)
    json = JSON.pretty_generate(data)
    File.write(path, json, encoding: 'utf-8')
    nil
  end

  # @param [Array<Node>] nodes
  # @return [Array<Hash>]
  def serialize_nodes(nodes)
    nodes.map(&:to_h)
  end

  Connection = Struct.new(:channel_id, :node)

  # @param [Array<Hash>] data
  # @return [Array<Node>]
  def deserialize_nodes(nodes_data)
    # @type [Hash{Integer => Node}] Node id to Node
    nodes_map = {}
    # @type [Hash{Integer => Connection}] Node id to Connection
    connections_map = {}
    # First recreate all the nodes without the connections.
    nodes = nodes_data.map { |data|
      type = data[:type].to_sym
      klass = Nodes.const_get(type)
      node = klass.deserialize(data)
      node.position = Geom::Point2d.new(*data[:position].values)
      node.label = data[:label]

      nodes_map[data[:id]] = node
      data[:input].each { |connector_data|
        id = connector_data[:id]
        channel_id = connector_data[:channel_id].to_sym
        unless node.class.input_channels.key?(channel_id)
          # This can happen when reading old sessions files.
          puts "Warning: Skipping input channel #{channel_id} for #{node.typename}"
          next
        end

        connections_map[id] = Connection.new(channel_id, node)
      }

      node
    }
    # Connect the nodes.
    nodes_data.each { |data|
      node = nodes_map[data[:id]]
      data[:output].each { |output_data|
        channel_id = output_data[:channel_id].to_sym
        unless node.class.output_channels.key?(channel_id)
          # This can happen when reading old sessions files.
          puts "Warning: Skipping output channel #{channel_id} for #{node.typename}"
          next
        end

        output = node.output(channel_id)
        output_data[:partners].each { |partner|
          connection = connections_map[partner]
          input = connection.node.input(connection.channel_id)
          input.connect_to(output)
        }
      }
    }
    nodes
  end

  def create_default_nodes
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 9, 0),
      Geom::Point3d.new(0, 9, 0),
    ]
    points_node = Nodes::PointsNode.new(points: points)
    points_node.position = Geom::Point2d.new(400, 10)

    tr1 = Geom::Transformation.scaling(1,2,3)
    tr_node1 = Nodes::TransformationNode.new(transformation: tr1)
    tr_node1.position = Geom::Point2d.new(50, 200)

    tr2 = Geom::Transformation.new(ORIGIN, Y_AXIS)
    tr_node2 = Nodes::TransformationNode.new(transformation: tr2)
    tr_node2.position = Geom::Point2d.new(300, 200)
    tr_node2.input(:transformation).connect_to(tr_node1.output(:transformation))

    transform1_node = Nodes::TransformNode.new
    transform1_node.position = Geom::Point2d.new(600, 130)
    transform1_node.input(:geom).connect_to(points_node.output(:geom))
    transform1_node.input(:transformation).connect_to(tr_node2.output(:transformation))

    tr3 = Geom::Transformation.new(Geom::Point3d.new(10, 20, 30))
    tr_node3 = Nodes::TransformationNode.new(transformation: tr3)
    tr_node3.position = Geom::Point2d.new(300, 300)

    draw_node = Nodes::DrawPointsNode.new
    draw_node.position = Geom::Point2d.new(850, 30)
    draw_node.input(:geom).connect_to(transform1_node.output(:geom))

    [points_node, tr_node1, tr_node2, tr_node3, transform1_node, draw_node]
  end

  def save_session(dialog)
    title = "Save Nodes"
    filter = "Nodes Sessions|*#{SESSION_FILE_EXTENSION}"
    response = UI.savepanel(title, nil, filter)
    return if response.nil?

    path = response
    unless path.end_with?(SESSION_FILE_EXTENSION)
      path = "#{path}#{SESSION_FILE_EXTENSION}"
    end

    puts "Write to: #{path}"
    write(path, @nodes)
  end

  def load_session(dialog)
    title = "Save Nodes"
    filter = "Nodes Sessions|*#{SESSION_FILE_EXTENSION}"
    response = UI.openpanel(title, nil, filter)
    return if response.nil?

    puts "Read from: #{response}"
    @nodes = read(response)
    update(dialog)
  end

  def reset_session(dialog)
    message = "Remove all nodes?"
    response = UI.messagebox(message, MB_OKCANCEL)
    return if response == IDCANCEL

    @nodes.clear
    update(dialog)
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
