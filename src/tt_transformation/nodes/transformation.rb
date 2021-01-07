require 'tt_transformation/nodes/node'

module TT::Plugins::TransformationInspector
  class TransformationNode < Node

    def initialize(transformation)
      raise TypeError unless transformation.is_a?(Geom::Transformation)
      super()
      self.data = transformation
      on_output(:points) do |stream|
        # puts "output: points (#{typename}:#{object_id})"
        # p [:points, input.class, input&.data]
        # if input&.is_a?(PointsNode)
        if stream.id = :points
          # puts "> POINTS"
          # puts "> POINTS >>> #{input.data}"
          # input&.data&.map { |item| item.transform(data) }
          # stream.data.map { |item| item.transform(data) }
          stream.input(:points).map { |item| item.transform(data) }
        else
          # puts "> NIL (P)"
          nil
        end
      end
      on_output(:transformation) do |stream|
        # puts "output: transformation (#{typename}:#{object_id})"
        # p [:transformation, input.class, input&.data]
        if stream.id = :transformation
        # if input&.is_a?(TransformationNode)
          # puts "> TRANSFORMATION"
          # (input&.data || IDENTITY) * data
          if stream.has_input?(:transformation)
            stream.input(:transformation) * data
          else
            data
          end
        else
          # puts "> NIL (T)"
          nil
        end
      end
    end

    private

    def data_as_hash
      data.to_a
    end

  end # class Node
end
