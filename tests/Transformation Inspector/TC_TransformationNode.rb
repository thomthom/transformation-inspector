require 'testup/testcase'

module TT::Plugins::TransformationInspector
module Tests
  class TC_TransformationNode < TestUp::TestCase

    def test_output_geom_missing_input
      tr1 = Geom::Transformation.scaling(1,2,3)
      tr1_node = TransformationNode.new(transformation: tr1)
      assert_raises(Node::MissingInput) do
        result = tr1_node.output(:geom).data
      end
    end

    def test_output_geom_with_points_input
      points = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node = PointsNode.new(points: points)

      tr1 = Geom::Transformation.scaling(1,2,3)
      tr1_node = TransformationNode.new(transformation: tr1)
      tr1_node.input(:geom).connect_to(pts_node.output(:geom))

      expected = points.map { |pt| pt.transform(tr1) }
      assert_equal(expected, tr1_node.output(:geom).data)
    end

    def test_output_geom_with_points_and_transformation_input
      points = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node = PointsNode.new(points: points)

      tr1 = Geom::Transformation.scaling(1,2,3)
      tr1_node = TransformationNode.new(transformation: tr1)

      tr2 = Geom::Transformation.new(ORIGIN, Y_AXIS)
      tr2_node = TransformationNode.new(transformation: tr2)

      tr1_node.input(:geom).connect_to(pts_node.output(:geom))
      tr1_node.input(:transformation).connect_to(tr2_node.output(:transformation))

      expected = points.map { |pt| pt.transform(tr2).transform(tr1) }
      assert_equal(expected, tr1_node.output(:geom).data)
    end

    def test_output_transformation_no_input
      tr1 = Geom::Transformation.scaling(1,2,3)
      tr1_node = TransformationNode.new(transformation: tr1)

      expected = [
        1.0, 0.0, 0.0, 0.0,
        0.0, 2.0, 0.0, 0.0,
        0.0, 0.0, 3.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
      ]
      assert_equal(expected, tr1_node.output(:transformation).data.to_a)
    end

    def test_output_transformation_with_transformation_input
      tr1 = Geom::Transformation.scaling(1,2,3)
      tr1_node = TransformationNode.new(transformation: tr1)

      tr2 = Geom::Transformation.new(ORIGIN, Y_AXIS)
      tr2_node = TransformationNode.new(transformation: tr2)
      tr2_node.input(:geom).connect_to(tr1_node.output(:geom))

      expected = [
        -1.0, 0.0, 0.0, 0.0,
        0.0, -0.0, 1.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0
      ]
      assert_equal(expected, tr2_node.output(:transformation).data.to_a)
    end

  end
end
end
