require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class TransformationNode < Node

    def initialize(transformation)
      # puts "initialize (#{typename}:#{object_id}) #{transformation.inspect}"
      raise TypeError unless transformation.is_a?(Geom::Transformation)
      super()
      @properties = transformation
    end

    input :points, "Points" # TODO: Rename stream :geom ?

    output :points, "Points" do |connection|
      connection.input.data.map { |item|
        # puts "> connection: #{connection.object_id}"
        # puts "> node: #{connection.node.typename}:#{connection.node.object_id}"
        # puts "> item: #{item.inspect}"
        # puts "> properties: #{connection.node.properties.inspect}"
        item.transform(connection.node.properties)
      }

      # connection.node.input(:points).data.map { |item| item.transform(properties) }
    end


    input :transformation, "Transformation"

    output :transformation, "Transformation" do |connection|
      if connection.has_input?
        connection.input.data * connection.node.properties # TODO: Correct order?
      else
        connection.node.properties
      end
    end

    private

    def data_as_hash
      data.to_a
    end

  end # class Node
end
