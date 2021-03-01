require 'tt_transformation/constants/view'
require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
module Nodes
  class DrawPointsNode < Node

    include ViewConstants

    # @param [Hash] data
    # @return [DrawPointsNode]
    def self.deserialize(data)
      options = {
        mode: data[:config][:mode],
        color: Sketchup::Color.new(*data[:config][:color]),
        line_width: data[:config][:line_width],
        stipple: data[:config][:stipple],
      }
      node = self.new(options)
      node
    end

    # @param [Hash] options
    def initialize(options = {})
      super()
      @config[:mode] = GL_LINE_LOOP
      @config[:color] = Sketchup::Color.new('orange').to_a
      @config[:line_width] = 2
      @config[:stipple] = STIPPLE_SOLID
      @config.merge!(options)
    end

    # @in [Enumerable<#transform>]
    input :geom, "Geom"

    # @out [Geom::Transformation]
    output :geom, "Geom" do
      input(:geom).data
    end

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
      {
        mode: config(:mode),
        color: config(:color).to_a,
        line_width: config(:line_width),
        stipple: config(:stipple),
      }
    end

  end # class Node
end # module Nodes
end
