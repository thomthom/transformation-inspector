require 'testup/testcase'

module TT::Plugins::TransformationInspector
module Tests
  class TC_PointsNode < TestUp::TestCase

    def test_output_geom
      points = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      node = Nodes::PointsNode.new(points: points)
      result = node.output(:geom)
      assert_kind_of(Nodes::Node::OutputConnectionPoint, result)
    end

    def test_output_geom_data
      points = [
        Geom::Point3d.new(1, 2, 3),
        Geom::Point3d.new(4, 5, 6),
      ]
      node = Nodes::PointsNode.new(points: points)
      assert_equal(points, node.output(:geom).data)
    end

  end
end
end
