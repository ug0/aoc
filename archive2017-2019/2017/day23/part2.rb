a = 1
d = e = f = g = h = 0
b = c = 93
if(a != 0)
  b = 100 * b + 100000
  c = b + 17000
end

while b <= c
  f = 1
  d = 2

  while d < b
    e = 2
    if(b % d == 0)
      f = 0
      break
    end
    d += 1
  end

  if(f == 0)
    h += 1
  end
  b += 17
end

puts h
