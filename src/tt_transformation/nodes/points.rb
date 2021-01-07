require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class PointsNode < Node

    def initialize(points)
      raise TypeError unless points.is_a?(Array)
      raise TypeError unless points.all? { |n| n.is_a?(Geom::Point3d) }
      super()
      @properties = points
    end

    output :points, "Points" do |connection|
      # puts "> output #{typename}:#{object_id}"
      connection.node.properties
    end

    private

    def properties_as_hash
      properties.to_a
    end

  end # class Node
end
