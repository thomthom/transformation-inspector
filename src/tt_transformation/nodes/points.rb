require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class PointsNode < Node

    def initialize(points: [])
      raise TypeError unless points.is_a?(Array)
      raise TypeError unless points.all? { |n| n.is_a?(Geom::Point3d) }
      super()
      config[:points] = points
    end

    output :points, "Points" do |connection|
      config[:points]
    end

  end # class Node
end
