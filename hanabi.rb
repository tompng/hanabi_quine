chars = ' ▘▝▀▖▌▞▛▗▚▐▜▄▙▟█'

srand 0

width = 160
height = 80
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

gravity = 0.5
wind = 0.1
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

new_split_time = -> { 0.5 + rand }
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
      v = (0.5 + 0.4*rand) * 536 ** rand.i
      spark.call x, y, vx + v.real, vy + v.imag, (life - dt) / 2 + 0.4 * rand, new_split_time.call, time - dt
    end.inject(:+)
  end
end

sparks = []

(0..).each do |i|
  clear.call
  dt = 1.0
  n = 200
  m = 40
  ti = i % (n+m)
  r = 0.12*[ti*0.05,1].min
  ay = -[ti.fdiv(n), 1, [(3*n+2*m-3.0*ti)/m,0].max].min
  ax = -ay*0.1
  cx = ax
  cy = ay + (ti > n ? gravity * (dt * (ti - n)) ** 2 / 2 : 0)
  ir = (2 * r / scale * width).ceil
  iy = (cy / scale * width / 2).ceil
  (iy-ir/2...[iy+ir/2,height/2].min).each do |iy|
    (-ir..ir).each do |ix|
      x = ix * scale / width
      y = 2.0 * iy * scale / width
      a=0.1*(Math.sin(4*x+5*y+ti)+Math.sin(-5*x+3*y+ti))
      canvas[height/2+iy][width/2+ix]=1 if ((x-cx)/r)**2+(y-cy).fdiv(r)**2+a<1
    end
  end
  ytop = -scale * height / width
  stroke.call(-ytop*0.1, ytop, -0.1,1,0,0, ay-ytop-r/2)
  rand(2..8).times do
    next if rand > (n-ti).fdiv(n)*2
    a = [0.2+ti*0.05,1].min
    sparks << [*(cx+cy.i).rect, *((1-a)*(-0.05+0.5.i) + a * (0.5 + 0.5*rand) * 536**rand.i).rect, 1 + rand, (1-a)+new_split_time.call]
  end if ti < n
  sparks = sparks.flat_map do |s|
    spark.call(*s, dt)
  end
  show.call
  sleep 0.1
end
