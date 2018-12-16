class Units < Array
  def add(unit)
    if empty? || !react?(last, unit)
      push(unit)
    else
      pop
    end
  end

  private

  def react?(a, b)
    a != b && a.upcase == b.upcase
  end
end




units = Units.new

File.read(ARGV[0])
    .chars
    .each do |unit|
      units.add(unit)
    end

puts units.length