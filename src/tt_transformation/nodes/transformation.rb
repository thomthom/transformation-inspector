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
        # TODO: use :transformation output
        item.transform(output)
      }
    end


    input :transformation, "Transformation"

    output :transformation, "Transformation" do |connection|
      if has_input?(:transformation)
        input(:transformation).data * properties # TODO: Correct order?
      else
        properties
      end
    end

    private

    def data_as_hash
      data.to_a
    end

  end # class Node
end
