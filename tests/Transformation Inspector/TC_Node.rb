require 'testup/testcase'

module TT::Plugins::TransformationInspector
module Tests
  class TC_Node < TestUp::TestCase

    def test_set_config_no_input
      points1 = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node = Nodes::PointsNode.new(points: points1)
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
      pts_node = Nodes::PointsNode.new(points: points)
      assert_equal(points, pts_node.output(:geom).data)

      tr1 = Geom::Transformation.scaling(1, 2, 3)
      tr1_node = Nodes::TransformationNode.new(transformation: tr1)

      transform1_node = Nodes::TransformNode.new
      transform1_node.input(:transformation).connect_to(tr1_node.output(:transformation))
      transform1_node.input(:geom).connect_to(pts_node.output(:geom))

      expected = points.map { |pt| pt.transform(tr1) }
      assert_equal(expected, transform1_node.output(:geom).data)

      tr2 = Geom::Transformation.scaling(4, 5, 6)
      tr1_node.set_config(:transformation, tr2)
      expected = points.map { |pt| pt.transform(tr2) }
      assert_equal(expected, transform1_node.output(:geom).data)
    end

    def test_set_config_propagate_update
      points1 = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node = Nodes::PointsNode.new(points: points1)

      tr1 = Geom::Transformation.scaling(1,2,3)
      tr1_node = Nodes::TransformationNode.new(transformation: tr1)

      tr2 = Geom::Transformation.new(ORIGIN, Y_AXIS)
      tr2_node = Nodes::TransformationNode.new(transformation: tr2)

      tr2_node.input(:transformation).connect_to(tr1_node.output(:transformation))

      transform1_node = Nodes::TransformNode.new
      transform1_node.input(:geom).connect_to(pts_node.output(:geom))
      transform1_node.input(:transformation).connect_to(tr2_node.output(:transformation))

      tr = tr2 * tr1

      expected = points1.map { |pt| pt.transform(tr) }
      assert_equal(expected, transform1_node.output(:geom).data)

      points2 = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node.set_config(:points, points2)

      expected = points2.map { |pt| pt.transform(tr) }
      assert_equal(expected, transform1_node.output(:geom).data)
    end

    def test_to_h_connector_ids
      points = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      pts_node = Nodes::PointsNode.new(points: points)

      tr1 = Geom::Transformation.scaling(1, 2, 3)
      tr1_node = Nodes::TransformationNode.new(transformation: tr1)

      transform1_node = Nodes::TransformNode.new
      transform1_node.input(:transformation).connect_to(tr1_node.output(:transformation))
      transform1_node.input(:geom).connect_to(pts_node.output(:geom))

      pts_hash = pts_node.to_h
      expected = transform1_node.input(:geom).object_id
      actual = pts_hash[:output][0][:partners][0]
      assert_equal(expected, actual, 'wrong partner ID for output')

      tr1_hash = tr1_node.to_h
      expected = transform1_node.input(:transformation).object_id
      actual = tr1_hash[:output][0][:partners][0]
      assert_equal(expected, actual, 'wrong partner ID for input')

      transform1_node_hash = transform1_node.to_h

      expected = pts_node.output(:geom).object_id
      actual = transform1_node_hash[:input][0][:partner]
      assert_equal(expected, actual, 'wrong partner ID for input')

      expected = tr1_node.output(:transformation).object_id
      actual = transform1_node_hash[:input][1][:partner]
      assert_equal(expected, actual, 'wrong partner ID for input')
    end

  end
end
end
