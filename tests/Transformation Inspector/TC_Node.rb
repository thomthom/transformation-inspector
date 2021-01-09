require 'testup/testcase'

module TT::Plugins::TransformationInspector
module Tests
  class TC_Node < TestUp::TestCase

    def test_set_config_no_input
      points1 = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node = PointsNode.new(points: points1)
      assert_equal(points1, pts_node.output(:geom).data)

      points2 = [
        Geom::Point3d.new(7, 8, 9),
        Geom::Point3d.new(4, 5, 6),
        Geom::Point3d.new(1, 2, 3),
      ]
      pts_node.set_config(:points, points2)
      assert_equal(points2, pts_node.output(:geom).data)
    end

    def test_set_config_with_input
      points = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node = PointsNode.new(points: points)
      assert_equal(points, pts_node.output(:geom).data)

      tr1 = Geom::Transformation.scaling(1, 2, 3)
      tr1_node = TransformationNode.new(transformation: tr1)
      tr1_node.input(:geom).connect_to(pts_node.output(:geom))

      expected = points.map { |pt| pt.transform(tr1) }
      assert_equal(expected, tr1_node.output(:geom).data)

      tr2 = Geom::Transformation.scaling(4, 5, 6)
      tr1_node.set_config(:transformation, tr2)
      expected = points.map { |pt| pt.transform(tr2) }
      assert_equal(expected, tr1_node.output(:geom).data)
    end

    def test_set_config_propagate_update
      points1 = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node = PointsNode.new(points: points1)

      tr1 = Geom::Transformation.scaling(1,2,3)
      tr1_node = TransformationNode.new(transformation: tr1)

      tr2 = Geom::Transformation.new(ORIGIN, Y_AXIS)
      tr2_node = TransformationNode.new(transformation: tr2)

      tr1_node.input(:geom).connect_to(pts_node.output(:geom))
      tr2_node.input(:geom).connect_to(tr1_node.output(:geom))

      expected = points1.map { |pt| pt.transform(tr1).transform(tr2) }
      assert_equal(expected, tr2_node.output(:geom).data)

      points2 = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node.set_config(:points, points2)

      expected = points2.map { |pt| pt.transform(tr1).transform(tr2) }
      assert_equal(expected, tr2_node.output(:geom).data)
    end

  end
end
end
