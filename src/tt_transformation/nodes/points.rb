require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class PointsNode < Node

    # @param [Hash] data
    # @return [PointsNode]
    def self.deserialize(data)
      points = data[:config][:points].map { |point_data|
        Geom::Point3d.new(*point_data)
      }
      node = self.new(points: points)
      node
    end

    # @param [Array<Geom::Point3d>] points
    def initialize(points: [])
      raise TypeError unless points.is_a?(Array)
      raise TypeError unless points.all? { |n| n.is_a?(Geom::Point3d) }
      super()
      @config[:points] = points
    end

    # @out [Enumerable<#transform>]
    output :geom, "Geom" do
      config(:points)
    end

    private

    def config_to_hash
      {
        points: config(:points).map { |pt| pt.to_a.map(&:to_f) }
      }
    end

  end # class Node
end
