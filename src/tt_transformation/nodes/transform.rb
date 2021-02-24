require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class TransformNode < Node

    # @param [Hash] data
    # @return [TransformNode]
    def self.deserialize(data)
      self.new
    end

    # @in [Enumerable<#transform>]
    input :geom, "Geom"

    # @in [Geom::Transformation]
    input :transformation, "Transformation"

    # @out [Enumerable<#transform>]
    output :geom, "Geom" do
      tr = input(:transformation).data
      input(:geom).data.map { |item|
        item.transform(tr)
      }
    end

    private

    def config_to_hash
      {
      }
    end

  end # class Node
end
