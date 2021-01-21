require 'tt_transformation/constants/view'
require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class DrawPointsNode < Node

    include ViewConstants

    def initialize
      super()
      # TODO:
      @config[:mode] = GL_LINE_LOOP
      @config[:color] = Sketchup::Color.new('orange').to_a
      @config[:line_width] = 2
      @config[:stipple] = STIPPLE_SOLID
    end

    # @in [Enumerable<#transform>]
    input :geom, "Geom"

    # @param [Sketchup::View] view
    def draw(view)
      puts "draw #{self}"
      return unless has_input?(:geom) && !input(:geom).data.empty?

      view.drawing_color = config(:color)
      view.line_width = config(:line_width)
      view.line_stipple = config(:stipple)
      begin
        view.draw(config(:mode), input(:geom).data)
      rescue => error
        puts error.message
      end
    rescue MissingInput
      # TODO: Indicate missing input in the UI.
    end

    private

    def invalidate_cache
      super
      # TODO: Use events instead for this.
      model = Sketchup.active_model
      view = model.active_view
      view.invalidate
    end

    def config_to_hash
      # {
      #   points: config(:points).map { |pt| pt.to_a.map(&:to_f) }
      # }
      # TODO:
      @config
    end

  end # class Node
end
