require 'json'

module TT::Plugins::TransformationInspector
  class Node

    class Error < StandardError; end

    class MissingInputChannel < Error; end
    class InvalidChannelId < Error; end
    class RecursiveAccess < Error; end

    # @input_channels = {} # @type [Hash{Symbol, InputChannel}]
    # @output_channels = {} # @type [Hash{Symbol, OutputChannel}]

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
    # @yield [connection]
    # @yieldparam [OutputConnectionPoint] connection
    def self.output(channel_id, label, &block)
      # puts "Creating output channel '#{label}' (#{channel_id}) for #{typename}"
      channel = OutputChannel.new(channel_id, label, block)
      output_channels[channel_id] = channel
    end

    # @param [Symbol] channel_id
    def self.output_processor(channel_id)
      raise InvalidChannelId, "#{channel_id}" unless output_channels.key?(channel_id)
      output_channels[channel_id].processor
    end


    def self.typename
      name.split('::').last
    end

    def typename
      self.class.typename
    end


    InputChannel = Struct.new(:id, :label)

    OutputChannel = Struct.new(:id, :label, :processor)

    class ConnectionPoint

      def self.typename
        name.split('::').last
      end

      def typename
        self.class.typename
      end

      attr_accessor :channel_id, :node

      def initialize(channel_id, node)
        @channel_id = channel_id
        @node = node
      end

    end

    class InputConnectionPoint < ConnectionPoint

      # @type [OutputConnectionPoint]
      attr_reader :partner

      # @param [OutputConnectionPoint] output
      def connect_to(output)
        raise TypeError, "got #{output.class}" unless output.is_a?(OutputConnectionPoint)
        # puts "connect #{typename}:#{object_id} (#{node.typename}:#{node.object_id}) " <<
        #      "to #{output.typename}:#{output.object_id} (#{output.node.typename}:#{output.node.object_id})"
        if partner
          partner.partners.delete(self)
        end
        @partner = output
        output.partners << self
        node.send(:invalidate_cache) # KLUDGE!
        # node.invalidate_cache
        # node.trigger_event(:update, self)
      end

      def data
        # puts "data (#{channel_id}) #{typename}:#{object_id} (#{node.typename}:#{node.object_id})"
        # puts "> node: #{node.typename}:#{node.object_id} (#{node.class})"
        # puts "> partner: #{partner&.typename}:#{partner&.object_id}"
        partner.data
      end

    end

    class OutputConnectionPoint < ConnectionPoint

      # @type [Set<InputConnectionPoint>]
      attr_reader :partners

      def initialize(channel_id, node)
        super(channel_id, node)
        @partners = Set.new
      end

      # # @param [InputConnectionPoint] input
      def connect_to(input)
        raise TypeError unless input.is_a?(InputConnectionPoint)
        input.connect_to(self)
      end


      def has_input?
        node.has_input?(channel_id)
      end

      # @return [InputConnectionPoint]
      def input
        node.input(channel_id)
      end


      def data
        # puts "data (#{channel_id}) #{typename}:#{object_id} (#{node.typename}:#{node.object_id})"
        raise RecursiveAccess if @updating
        if @data.nil?
          begin
            @updating = true
            @data = node.class.output_processor(channel_id).call(self)
          ensure
            @updating = false
          end
        end
        @data
      end

      # @private
      def invalidate_cache
        @data = nil
      end

    end


    attr_reader :properties

    def initialize
      # puts "INITIALIZE #{self.typename}:#{object_id}"
      @label = 'Untitled'

      @position = Geom::Point2d.new

      # @type [Object]
      @properties = nil

      # @type [Hash<Symbol, InputConnectionPoint>]
      @input = {}

      # @type [Hash<Symbol, OutputConnectionPoint>]
      @output = {}
    end


    # def properties
    #   @properties
    # end

    # def properties=(value)
    #   # puts "SET #{self.typename}:#{object_id} data: #{value}"
    #   @properties = value
    # end


    def has_input?(channel_id)
      @input.key?(channel_id)
    end

    def input(channel_id)
      # puts "input(#{channel_id}) #{typename}:#{object_id}"
      raise InvalidChannelId, "#{channel_id}" unless self.class.input_channels.key?(channel_id)
      @input[channel_id] ||= InputConnectionPoint.new(channel_id, self)
      @input[channel_id]
    end


    def has_output?(channel_id)
      @output.key?(channel_id)
    end

    def output(channel_id)
      # puts "output(#{channel_id}) #{typename}:#{object_id}"
      raise InvalidChannelId, "#{channel_id}" unless self.class.output_channels.key?(channel_id)
      @output[channel_id] ||= OutputConnectionPoint.new(channel_id, self)
      @output[channel_id]
    end


    # def to_h
    #   {
    #     label: @label,
    #     position: @position.to_a,
    #     input: @input.object_id,
    #     output: @output.map(&:to_h),
    #     data: data_as_json,
    #   }
    # end

    # def to_json
    #   to_h.to_json
    # end

    private

    def trigger_event(event_id, node)
      # puts "event: #{event_id} (#{typename}:#{object_id})"
    end

    def invalidate_cache
      # puts "invalidate_cache (#{typename}:#{object_id})"
      @output.each { |channel_id, output_point|
        # puts "> #{stream_id}, (#{stream.id})"
        output_point.invalidate_cache
      }
    end

  end # class Node
end
