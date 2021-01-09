require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class PointsNode < Node

    # @param [Array<Geom::Point3d>] points
    def initialize(points: [])
      raise TypeError unless points.is_a?(Array)
      raise TypeError unless points.all? { |n| n.is_a?(Geom::Point3d) }
      super()
      config[:points] = points
    end

    # @out [Enumerable<#transform>]
    output :geom, "Geom" do
      config[:points]
    end

  end # class Node
end
