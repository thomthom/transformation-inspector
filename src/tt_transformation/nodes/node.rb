require 'json'

module TT::Plugins::TransformationInspector
  class Node

    class Error < StandardError; end

    class MissingInputStream < Error; end
    class InvalidStreamName < Error; end
    class RecursiveStream < Error; end

    # parent = input
    Stream = Struct.new(:id, :label, :parent, :processor, :nodes) do

      def has_input?(stream_id)
        !parent.input.has_output?(stream_id)
      end

      def input(stream_id)
        parent.input.output(stream_id).data
      end

      def data
        raise RecursiveStream if @updating
        # puts "> Stream.data (#{object_id}) (Node: #{parent.typename}:#{parent.object_id})"
        if @data.nil?
          begin
            @updating = true
            @data = processor.call(self)
          ensure
            @updating = false
          end
        end
        # @data ||= processor.call(self)
        # puts "> Stream.data (#{object_id}) >>> #{@data}"
        @data
      end

      def invalidate_cache
        # puts "> Stream.invalidate_cache (#{object_id}) (Node: #{parent.typename}:#{parent.object_id})"
        @data = nil
      end

      def to_h
        {
          id: @id,
          label: @label,
          # data: @data,
          nodes: @nodes.map(&:object_id),
        }
      end

    end # Stream


    def self.typename
      name.split('::').last
    end

    def initialize
      # puts "INITIALIZE #{self.typename}:#{object_id}"
      @state = {
        label: 'Untitled',
        position: Geom::Point2d.new,
        input: nil, # @type [Node, nil]
        output: {}, # @type [Hash<Symbol, Stream>]
        data: nil, # @type [Object]
      }
      # @stream_processors = {}
    end


    def typename
      self.class.typename
    end


    def data
      # puts "GET #{self.typename}:#{object_id} data"
      # puts "GET #{self.typename}:#{object_id} >>> #{@state[:data].inspect}"
      @state[:data]
    end

    def data=(value)
      # puts "SET #{self.typename}:#{object_id} data: #{value}"
      @state[:data] = value
    end


    def input
      @state[:input]
    end

    def input=(stream)
      raise TypeError unless stream.is_a?(Stream)
      if @state[:input]
        @state[:input].delete(self)
      end
      @state[:input] = stream.parent # TODO: Rename source_node or input
      stream.nodes << self
      invalidate_cache
      trigger_event(:update, self)
    end


    def has_output?(stream_id)
      @state[:output].key?(stream_id)
    end

    def output(stream_id)
      # puts "output get: #{stream_id} (#{self.typename})"
      # p @state[:output][stream_id]
      @state[:output][stream_id] || (raise ArgumentError, "unknown stream: #{stream_id}")
    end


    def to_h
      {
        label: @state[:label],
        position: @state[:position].to_a,
        input: @state[:input].object_id,
        output: @state[:output].map(&:to_h),
        data: data_as_json,
      }
    end

    def to_json
      to_h.to_json
    end

    private

    def on_output(stream_id, &block)
      # puts "on_output: #{stream_id} (#{self.typename}:#{object_id})"
      # @stream_processors[stream_id] = block
      stream_label = stream_id # TODO:
      # stream_data = block.call # TODO: Lazy generate.
      stream_nodes = Set.new
      # @state[:output][stream_id] = Stream.new(stream_id, stream_label, stream_data, block, stream_nodes)
      # p [:block, block]
      @state[:output][stream_id] = Stream.new(stream_id, stream_label, self, block, stream_nodes)
    end

    def trigger_event(event_id, node)
      # puts "event: #{event_id} (#{typename}:#{object_id})"
    end

    def invalidate_cache
      # puts "invalidate_cache (#{typename}:#{object_id})"
      @state[:output].each { |stream_id, stream|
        # puts "> #{stream_id}, (#{stream.id})"
        # stream.data = stream.processor.call # TODO: Lazy generate.
        stream.invalidate_cache
      }
    end

  end # class Node
end
