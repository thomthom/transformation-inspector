require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
module Nodes
  class TransformationNode < Node

    # @param [Hash] data
    # @return [TransformationNode]
    def self.deserialize(data)
      transformation = Geom::Transformation.new
      transformation.set!(data[:config][:transformation])
      node = self.new(transformation: transformation)
      node
    end

    # @param [Geom::Transformation] transformation
    def initialize(transformation: IDENTITY)
      raise TypeError unless transformation.is_a?(Geom::Transformation)
      super()
      @config[:transformation] = transformation
    end

    # @in [Geom::Transformation]
    input :transformation, "Transformation"

    # @out [Geom::Transformation]
    output :transformation, "Transformation" do
      if has_input?(:transformation)
        # Not sure what the best order of combination is. Need to experiment.
        #
        # N(pt) ----------+
        #                 +-> N(pt*t)
        # N(t1) -> N(t2) -+
        # =
        # pt.transform(t1).transform(t2)
        # =
        # pt.transform(t2 * t1)
        config(:transformation) * input(:transformation).data
      else
        config(:transformation)
      end
    end

    private

    def config_to_hash
      {
        transformation: config(:transformation).to_a
      }
    end

  end # class Node
end # module Nodes
end
