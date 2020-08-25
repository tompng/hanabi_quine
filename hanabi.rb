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

clear = lambda do
  canvas.each do |line|
    width.times { line[_1] = 0 }
  end
end

gravity = 1
wind = 0.2
scale = 4.0
stroke = lambda do |x, y, vx, vy, ax, ay, time|
  vmax = [vx, vx + ax * time, 2 * vy, (vy + ay * time) / 2].map(&:abs).max
  step = width * (vmax * time) / scale
  (0..step).each do |i|
    t = time * i.fdiv(step)
    px = x + vx * t + ax * t * t / 2
    py = y + vy * t + ay * t * t / 2
    ix = (width / 2 + px / scale * width).round
    iy = (height / 2 + py / scale * width / 2).round
    canvas[iy][ix] = 1 if (0...width).cover?(ix) && (0...height).cover?(iy)
  end
end

new_split_time = -> { 0.4 + 0.9 * rand }
spark = lambda do |x, y, vx, vy, life, split_time, time|
  dt = [time, life, split_time].min
  stroke.call x, y, vx, vy, wind, gravity, dt
  x += vx * dt + wind * dt * dt / 2
  y += vy * dt + gravity * dt * dt / 2
  vx += wind * dt
  vy += gravity * dt
  if dt == life
    []
  elsif dt == time
    [[x, y, vx, vy, life - dt, split_time - dt]]
  else
    n = rand(5..10)
    n.times.map do
      v = (1 + rand) * 536 ** rand.i
      spark.call x, y, vx + v.real, vy + v.imag, (life - dt) / 4 + 0.2 * rand, new_split_time.call, time - dt
    end.inject(:+)
  end
end

sparks = []

(1..).each do |ti|
  clear.call
  r = 0.12
  cx = 0.1 * Math.sin(ti * 0.07)
  cy = 0.1 * Math.sin(ti * 0.13)
  ir = ((2 * r+cx.abs) / scale * width).ceil
  (-ir..ir).each do |ix|
    (-ir/2..ir/2).each do |iy|
      x = ix * scale / width
      y = 2.0 * iy * scale / width
      a=0.1*(Math.sin(4*x+5*y+ti)+Math.sin(-5*x+3*y+ti))
      canvas[height/2+iy][width/2+ix]=1 if (x-cx)**2+(y-cy)**2+r*r*a<r**2
    end
  end
  stroke.call(cx,0,0,-1,0.05,0, scale * height / width)
  dt = 0.5
  rand(2..12).times do
    sparks << [*(cx+cy.i + 0.1 * 536**rand.i).rect, *((0.5 + rand) * 536**rand.i).rect, 2 * rand, new_split_time.call] if rand < dt
  end
  sparks = sparks.flat_map do |s|
    spark.call(*s, dt)
  end
  show.call
  sleep 0.1
end
