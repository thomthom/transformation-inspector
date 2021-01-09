require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class TransformationNode < Node

    # @param [Geom::Transformation] transformation
    def initialize(transformation: IDENTITY)
      raise TypeError unless transformation.is_a?(Geom::Transformation)
      super()
      config[:transformation] = transformation
    end

    # @in [Enumerable<#transform>]
    input :geom, "Geom"

    # @out [Enumerable<#transform>]
    output :geom, "Geom" do
      tr = output(:transformation).data
      input(:geom).data.map { |item|
        item.transform(tr)
      }
    end


    # @in [Geom::Transformation]
    input :transformation, "Transformation"

    # @out [Geom::Transformation]
    output :transformation, "Transformation" do
      if has_input?(:transformation)
        # Not sure what the best order of combination is. Need to experiment.
        #
        # N(pt) -> N(t1) -> N(t2)
        # =
        # pt.transform(t1).transform(t2)
        # =
        # pt.transform(t2 * t1)
        config[:transformation] * input(:transformation).data
      else
        config[:transformation]
      end
    end

  end # class Node
end
