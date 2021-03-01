require 'testup/testcase'

module TT::Plugins::TransformationInspector
module Tests
  class TC_TransformNode < TestUp::TestCase

    def test_output_geom_missing_geom_input
      tr1 = Geom::Transformation.scaling(1,2,3)
      tr1_node = Nodes::TransformationNode.new(transformation: tr1)

      transform1_node = Nodes::TransformNode.new
      transform1_node.input(:transformation).connect_to(tr1_node.output(:transformation))

      assert_raises(Nodes::Node::MissingInput) do
        result = transform1_node.output(:geom).data
      end
    end

    def test_output_geom_missing_transform_input
      points = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node = Nodes::PointsNode.new(points: points)

      transform1_node = Nodes::TransformNode.new
      transform1_node.input(:geom).connect_to(pts_node.output(:geom))

      assert_raises(Nodes::Node::MissingInput) do
        result = transform1_node.output(:geom).data
      end
    end

    def test_output_geom_with_points_and_transformation_input
      points = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node = Nodes::PointsNode.new(points: points)

      tr1 = Geom::Transformation.scaling(1,2,3)
      tr1_node = Nodes::TransformationNode.new(transformation: tr1)

      transform1_node = Nodes::TransformNode.new
      transform1_node.input(:transformation).connect_to(tr1_node.output(:transformation))
      transform1_node.input(:geom).connect_to(pts_node.output(:geom))

      expected = points.map { |pt| pt.transform(tr1) }
      assert_equal(expected, transform1_node.output(:geom).data)
    end

  end
end
end
