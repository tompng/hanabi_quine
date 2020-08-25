chars = ' ▘▝▀▖▌▞▛▗▚▐▜▄▙▟█'

srand 0

width = 160
height = 96
canvas = height.times.map { [0] * width }

show = lambda do
  lines = (height / 2).times.map do |j|
    (width / 2).times.map do |i|
      chars[4.times.map{|k|canvas[2*j+k/2][2*i+k%2]<<k}.sum]
    end.join
  end
  puts "\e[1;1H" + lines.join("\n")
end



gravity = 1
wind = 0.5
scale = 4
stroke = lambda do |x, y, vx, vy, time|
  vmax = [vx, vx + wind * time, 2 * vy, (vy + gravity * time) / 2].map(&:abs).max
  step = width * (vmax * time) / scale
  (0..step).each do |i|
    t = time * i.fdiv(step)
    px = x + vx * t + wind * t * t / 2
    py = y + vy * t + gravity * t * t / 2
    ix = (width / 2 + px / scale * width).round
    iy = (height / 2 + py / scale * width / 2).round
    canvas[iy][ix] = 1 if (0...width).cover?(ix) && (0...height).cover?(iy)
  end
end

spark = lambda do |x, y, vx, vy, life, time|
  split_time = 0.4 + 0.9 * rand
  dt = [time, life, split_time].min
  stroke.call x, y, vx, vy, dt
  x += vx * dt + wind * dt * dt / 2
  y += vy * dt + gravity * dt * dt / 2
  vx += wind * dt
  vy += gravity * dt
  if dt == life
    []
  elsif dt == time
    [x, y, vx, vy, life - dt]
  else
    n = rand(5..10)
    n.times.map do
      v = (1 + rand) * 536 ** rand.i
      spark.call x, y, vx + v.real, vy + v.imag, (life - dt) / 4 + 0.25 * rand, time - dt
    end.inject(:+)
  end
end

20.times do |i|
  spark.call 0, 0, *(536**(i/20.0).i).rect, 2, 2
end

show.call