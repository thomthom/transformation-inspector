require 'tt_transformation/nodes/node'

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
    points_node = PointsNode.new(points)

    # puts '1-------------------'

    tr1 = Geom::Transformation.scaling(1,2,3)
    tr_node1 = TransformationNode.new(tr1)
    tr_node1.input(:points).connect_to(points_node.output(:points))

    # puts '2-------------------'

    tr2 = Geom::Transformation.new(ORIGIN, Y_AXIS)
    tr_node2 = TransformationNode.new(tr2)
    tr_node2.input(:points).connect_to(tr_node1.output(:points))

    # puts '3-------------------'

    print_points(:points, points)
    puts
    print_points(:points_node, points_node.output(:points).data)

    puts
    print_points(:tr_node1, tr_node1.output(:points).data)
    print_transformation(:tr_node1, tr_node1.output(:transformation).data)

    puts
    print_points(:tr_node2, tr_node2.output(:points).data)
    print_transformation(:tr_node2, tr_node2.output(:transformation).data)

    # loop_draw_node = DrawLoopNode.new
    # loop_draw_node.input = tr_node1.output(:points)

    # quad_draw_node = DrawQuadNode.new
    # quad_draw_node.input = tr_node1.output(:points)
    nil
  end

end
