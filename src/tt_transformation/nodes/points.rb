require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class PointsNode < Node

    def initialize(points)
      raise TypeError unless points.is_a?(Array)
      raise TypeError unless points.all? { |n| n.is_a?(Geom::Point3d) }
      super()
      # TODO: Takes no input.
      self.data = points
      on_output(:points) do |stream|
        # puts "output: points (#{typename}:#{object_id})"
        data
      end
    end

    private

    def data_as_hash
      data.to_a
    end

  end # class Node
end
