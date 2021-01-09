require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class TransformationNode < Node

    def initialize(transformation: IDENTITY)
      raise TypeError unless transformation.is_a?(Geom::Transformation)
      super()
      config[:transformation] = transformation
    end

    input :points, "Points" # TODO: Rename stream :geom ?

    output :points, "Points" do |connection|
      tr = output(:transformation).data
      input(:points).data.map { |item|
        item.transform(tr)
      }
    end


    input :transformation, "Transformation"

    output :transformation, "Transformation" do |connection|
      if has_input?(:transformation)
        input(:transformation).data * config[:transformation] # TODO: Correct order?
      else
        config[:transformation]
      end
    end

  end # class Node
end
