require 'json'

module TT::Plugins::TransformationInspector
  class Node

    class Error < StandardError; end

    class InvalidConfigKey < Error; end
    class InvalidChannelId < Error; end
    class MissingInput < Error; end
    class RecursiveAccess < Error; end
    class RecursiveConnection < Error; end

    # @return [Hash{Symbol, InputChannel}]
    def self.input_channels
      @input_channels ||= {}
      @input_channels
    end

    # @return [Hash{Symbol, OutputChannel}]
    def self.output_channels
      @output_channels ||= {}
      @output_channels
    end


    # @param [Symbol] channel_id
    # @param [String] label
    def self.input(channel_id, label)
      channel = InputChannel.new(channel_id, label)
      input_channels[channel_id] = channel
    end

    # @param [Symbol] channel_id
    # @param [String] label
    def self.output(channel_id, label, &block)
      channel = OutputChannel.new(channel_id, label, block)
      output_channels[channel_id] = channel
    end

    # @param [Symbol] channel_id
    # @raise [InvalidChannelId] if the channel id is not valid
    def self.output_processor(channel_id)
      raise InvalidChannelId, "#{channel_id}" unless output_channels.key?(channel_id)
      output_channels[channel_id].processor
    end


      # @return [String]
    def self.typename
      name.split('::').last
    end

      # @return [String]
    def typename
      self.class.typename
    end


    InputChannel = Struct.new(:id, :label)

    OutputChannel = Struct.new(:id, :label, :processor)

    class ConnectionPoint

      # @return [String]
      def self.typename
        name.split('::').last
      end

      # @return [String]
      def typename
        self.class.typename
      end

      attr_accessor :channel_id, :node

      # @param [Symbol] channel_id
      # @param [Node] node
      def initialize(channel_id, node)
        @channel_id = channel_id
        @node = node
      end

      def to_h
        {
          id: object_id,
          type: typename.to_sym,
          channel_id: channel_id,
          node: node&.object_id,
        }
      end

      def to_s
        "#{typename}:#{object_id}"
      end

      def inspect
        "#<#{to_s} channel_id=#{channel_id.inspect}>"
      end

    end

    class InputConnectionPoint < ConnectionPoint

      # @type [OutputConnectionPoint]
      attr_reader :partner

      # @param [OutputConnectionPoint] output
      def connect_to(output)
        node.connect(self, output)
      end

      # @param [OutputConnectionPoint] output
      def disconnect_from(output)
        node.disconnect(self, output)
      end

      def data
        raise MissingInput, "missing input on: #{channel_id}" if partner.nil?
        partner.data
      end

      def to_h
        super.merge({
          partner: partner&.object_id
        })
      end

      def inspect
        "#<#{to_s} channel_id=#{channel_id.inspect}, partner=#{partner&.object_id.inspect}>"
      end

      # @private
      # @param [OutputConnectionPoint] output
      def partner=(output)
        raise TypeError, "got #{output.class}" unless output.nil? || output.is_a?(OutputConnectionPoint)
        @partner = output
      end

    end

    class OutputConnectionPoint < ConnectionPoint

      # @type [Set<InputConnectionPoint>]
      attr_reader :partners

      # @param [Symbol] channel_id
      # @param [Node] node
      def initialize(channel_id, node)
        super(channel_id, node)
        @partners = Set.new
      end

      # @param [InputConnectionPoint] input
      def connect_to(input)
        node.connect(input, self)
      end

      # @param [InputConnectionPoint] input
      def disconnect_from(input)
        node.disconnect(input, self)
      end

      def data
        raise RecursiveAccess if @updating
        if @data.nil?
          begin
            @updating = true
            processor = node.class.output_processor(channel_id)
            @data = node.instance_exec(self, &processor)
          ensure
            @updating = false
          end
        end
        @data
      end

      def to_h
        super.merge({
          partners: partners.map(&:object_id)
        })
      end

      # @private
      def invalidate_cache
        # TODO: Use events to invalidate the output.
        @data = nil
      end

    end


    attr_reader :label, :position

    def initialize
      @label = 'Untitled'

      @position = Geom::Point2d.new

      # User input for the node's configuration.
      @config = {}

      # @type [Hash<Symbol, InputConnectionPoint>]
      @input = {}
      self.class.input_channels.keys.each { |channel_id|
        @input[channel_id] = InputConnectionPoint.new(channel_id, self)
      }

      # @type [Hash<Symbol, OutputConnectionPoint>]
      @output = {}
      self.class.output_channels.keys.each { |channel_id|
        @output[channel_id] = OutputConnectionPoint.new(channel_id, self)
      }
    end


    # @param [Geom::Point2d] point
    def position=(point)
      raise TypeError unless point.is_a?(Geom::Point2d)
      @position = point
    end


    # @param [Symbol] key
    def config(key)
      raise InvalidConfigKey, "invalid config key: #{key}" unless @config.key?(key)
      @config[key]
    end

    # @param [Symbol] key
    # @param [Object] value
    # @return [nil]
    def set_config(key, value)
      raise InvalidConfigKey, "invalid config key: #{key}" unless @config.key?(key)
      @config[key] = value
      invalidate_cache
      # trigger_event(:update, self)
      nil
    end


    # @param [Symbol] channel_id
    def has_input?(channel_id)
      !@input[channel_id].partner.nil?
    end

    # @param [Symbol] channel_id
    # @return [InputConnectionPoint]
    # @raise [InvalidChannelId] if the channel id is not valid
    def input(channel_id)
      raise InvalidChannelId, "#{channel_id}" unless self.class.input_channels.key?(channel_id)
      @input[channel_id]
    end


    # @param [Symbol] channel_id
    def has_output?(channel_id)
      !@output[channel_id].partners.empty?
    end

    # @param [Symbol] channel_id
    # @return [InputConnectionPoint]
    # @raise [InvalidChannelId] if the channel id is not valid
    def output(channel_id)
      raise InvalidChannelId, "#{channel_id}" unless self.class.output_channels.key?(channel_id)
      @output[channel_id]
    end


    # @param [InputConnectionPoint] input
    # @param [OutputConnectionPoint] output
    def connect(input, output)
      raise TypeError, "got #{input.class}" unless input.is_a?(InputConnectionPoint)
      raise TypeError, "got #{output.class}" unless output.is_a?(OutputConnectionPoint)
      raise RecursiveConnection, "cannot connect to itself" if input.node == output.node
      if input.partner
        input.partner.partners.delete(self)
      end
      input.partner = output
      output.partners << input
      invalidate_cache
      # trigger_event(:update, self)
      nil
    end

    # @param [InputConnectionPoint] input
    # @param [OutputConnectionPoint] output
    def disconnect(input, output)
      raise TypeError, "got #{input.class}" unless input.is_a?(InputConnectionPoint)
      raise TypeError, "got #{output.class}" unless output.is_a?(OutputConnectionPoint)
      # TODO: Validate there is a connection.
      input.partner = nil
      output.partners.delete(input)
      invalidate_cache
      # trigger_event(:update, self)
      nil
    end


    def to_h
      # TODO: Implement a serialize_hash/deserialize_hash scheme.
      # TODO: Implement a type handler system for serialization.
      {
        id: object_id,
        type: typename.to_sym,
        label: @label,
        position: { x: @position.x.to_f, y: position.y.to_f },
        input: @input.values.map!(&:to_h),
        output: @output.values.map!(&:to_h),
        config: config_to_hash,
      }
    end

    def to_json
      to_h.to_json
    end

    def to_s
      "#{typename}:#{object_id}"
    end

    def inspect
      "#<#{to_s} label=#{label.inspect}>"
    end

    private

    # @param [Symbol] event_id
    # @param [Node] node
    def trigger_event(event_id, node)
      nil
    end

    def invalidate_cache
      @output.each { |channel_id, output_point|
        output_point.invalidate_cache
      }
      # trigger_event(:update, self)
      nil
    end

  end # class Node
end
