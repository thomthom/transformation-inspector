require 'testup/testcase'

module TT::Plugins::TransformationInspector
module Tests
  class TC_TransformationNode < TestUp::TestCase

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
      tr2_node.input(:transformation).connect_to(tr1_node.output(:transformation))

      expected = [
        -1.0, 0.0, 0.0, 0.0,
        0.0, 0.0, 2.0, 0.0,
        0.0, 3.0, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0
      ]
      assert_equal(expected, tr2_node.output(:transformation).data.to_a)
    end

  end
end
end
