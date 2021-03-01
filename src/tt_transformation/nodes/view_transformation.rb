require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
module Nodes
  class ViewTransformationNode < Node

    # @param [Hash] data
    # @return [ViewTransformationNode]
    def self.deserialize(data)
      self.new
    end

    # @in [Geom::Transformation]
    input :transformation, "Transformation"

    # @out [Geom::Transformation]
    output :transformation, "Transformation" do
      input(:transformation).data
    end

    private

    def invalidate_cache
      super
      # TODO: Use events instead for this.
      # model = Sketchup.active_model
      # view = model.active_view
      # view.invalidate
      trigger_event(:update_config, self)
    end

    def config_to_hash
      puts "config_to_hash #{self}"
      # KLUGE: Abusing the config property to pass data to the JS app.
      tr = has_input?(:transformation) ? input(:transformation).data : IDENTITY
      {
        transformation: tr.to_a
      }
    end

  end # class Node
end # module Nodes
end
