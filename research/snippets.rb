def dump(transformation)
  columns = transformation.to_a.each_slice(4).map { |column|
    column.map(&:to_f)
  }
  rows = columns.transpose
  rows.each { |row|
    p row.map { |value| value.round(3) }
  }
  nil
end

