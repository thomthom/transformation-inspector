require 'tt_transformation/nodes/draw_points'
require 'tt_transformation/nodes/node'
require 'tt_transformation/nodes/points'
require 'tt_transformation/nodes/transformation'
require 'tt_transformation/nodes/view_transformation'

# TT::Plugins::TransformationInspector.example
module TT::Plugins::TransformationInspector

  def self.print_transformation(title, transformation)
    puts
    puts title
    tr = transformation.to_a
    puts "%10.6f %10.6f %10.6f %10.6f" % [ tr[0], tr[4], tr[8],  tr[12] ]
    puts "%10.6f %10.6f %10.6f %10.6f" % [ tr[1], tr[5], tr[9],  tr[13] ]
    puts "%10.6f %10.6f %10.6f %10.6f" % [ tr[2], tr[6], tr[10], tr[14] ]
    puts "%10.6f %10.6f %10.6f %10.6f" % [ tr[3], tr[7], tr[11], tr[15] ]
  end

  def self.print_3x3_transformation(title, transformation)
    puts
    puts "#{title} (3x3)"
    tr = transformation.to_a
    puts "%10.6f %10.6f %10.6f" % [ tr[0], tr[4], tr[12] ]
    puts "%10.6f %10.6f %10.6f" % [ tr[1], tr[5], tr[13] ]
    puts "%10.6f %10.6f %10.6f" % [ tr[3], tr[7], tr[15] ]
  end

  def self.print_points(title, points)
    puts
    puts "#{title}"
    points.each { |point|
      data = point.to_a.map { |n| "%10.6f" % [ n ] }
      puts "#{point.class}(#{data.join(',')})"
    }
  end

  def self.example
    points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(9, 0, 0),
      Geom::Point3d.new(9, 9, 0),
      Geom::Point3d.new(0, 9, 0),
    ]
    points_node = PointsNode.new(points: points)

    # puts '1-------------------'

    tr1 = Geom::Transformation.scaling(1,2,3)
    tr_node1 = TransformationNode.new(transformation: tr1)

    transform1 = TransformNode.new
    transform1.input(:geom).connect_to(points_node.output(:geom))
    transform1.input(:transformation).connect_to(tr_node1.output(:transformation))

    # puts '2-------------------'

    tr2 = Geom::Transformation.new(ORIGIN, Y_AXIS)
    tr_node2 = TransformationNode.new(transformation: tr2)
    tr_node2.input(:geom).connect_to(tr_node1.output(:geom))

    # puts '3-------------------'

    print_points(:points, points)
    puts
    print_points(:points_node, points_node.output(:geom).data)

    puts
    print_points(:tr_node1, tr_node1.output(:geom).data)
    print_transformation(:tr_node1, tr_node1.output(:transformation).data)

    puts
    print_points(:tr_node2, tr_node2.output(:geom).data)
    print_transformation(:tr_node2, tr_node2.output(:transformation).data)

    # loop_draw_node = DrawLoopNode.new
    # loop_draw_node.input = tr_node1.output(:points)

    # quad_draw_node = DrawQuadNode.new
    # quad_draw_node.input = tr_node1.output(:points)

    puts
    puts JSON.pretty_generate(points_node.to_h)
    puts JSON.pretty_generate(tr_node1.to_h)
    puts JSON.pretty_generate(tr_node2.to_h)

    tr3 = Geom::Transformation.rotation(ORIGIN, Z_AXIS, 30.degrees)
    tr_node3 = TransformationNode.new(transformation: tr3)
    puts JSON.pretty_generate(tr_node3.to_h)
    nil
  end

end
