require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class DrawPointsNode < Node

    def initialize
      super()
      # TODO:
      @config[:mode] = 'GL_LINE_LOOP'
      @config[:color] = Sketchup::Color.new('orange').to_a
      @config[:line_width] = 2
      @config[:stipple] = 'Solid'
    end

    # @in [Enumerable<#transform>]
    input :geom, "Geom"

    private

    def config_to_hash
      # {
      #   points: config(:points).map { |pt| pt.to_a.map(&:to_f) }
      # }
      # TODO:
      @config
    end

  end # class Node
end
