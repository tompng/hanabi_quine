chars = ' ▘▝▀▖▌▞▛▗▚▐▜▄▙▟█'
size=160
canvas = (size / 2).times.map { [0] * size }
show = lambda do
  lines = (size / 4).times.map do |j|
    (size / 2).times.map do |i|
      chars[4.times.map{|k|canvas[2*j+k/2][2*i+k%2]<<k}.sum]
    end.join
  end
  puts "\e[1;1H" + lines.join("\n")
end

g = 0.5
scale = 4.0
stroke = lambda do |p, v, a, time|
  v2 = v + a * time
  vmax = [v.real,v2.real,v.imag*0.5,v2.imag*0.5].map(&:abs).max
  step = (size * (vmax * time) / scale).ceil
  (0..step).each do
    t = time * _1.fdiv(step)
    q=p+v*t+a*t*t/2
    ix = (size / 2 + q.real / scale * size).round
    iy = (size / 4 + q.imag / scale * size / 2).round
    canvas[iy][ix] = 1 if (0...size).cover?(ix) && (0...size/2).cover?(iy)
  end
end

spark = lambda do |p, v, lt, st, tt|
  t = [tt, lt, st].min
  stroke[p,v,g.i,t]
  p+=v*t+g.i*t*t/2
  v+=g.i*t
  if t == lt
    []
  elsif t == tt
    [[p, v, lt - t, st - t]]
  else
    (0..rand(4..9)).flat_map do
      w = (0.5 + 0.4*rand) * 536 ** rand.i
      spark[p, v+w, (lt - t) / 2 + 0.4 * rand, 8, tt - t]
    end
  end
end

sparks = []

(0..).each do |i|
  canvas.map { |l| size.times { l[_1] = 0 } }
  n = 200
  m = 40
  ti = i % (n+m)
  ti==0&&srand(0)
  t=[0,(3*n+2*m-3.0*ti)/m,1].sort[1]
  dir=0.1-1i
  burn = [ti.fdiv(n),t*t*(3-2*t)].min
  ball = burn*dir + (ti > n ? g * (ti - n) ** 2 / 2.0 : 0).i
  r = 0.12*[ti*0.05,1].min
  ir = (2 * r / scale * size).ceil
  iy0 = (ball.imag / scale * size / 2).ceil
  (iy0-ir/2...iy0+ir/2).each do |iy|
    iy < size/4 && (-ir..ir).each do |ix|
      p = (ix +iy*2i)* scale / size
      canvas[size/4+iy][size/2+ix]=1 if (p-ball).abs<r
    end
  end
  [-1,1].map{stroke[dir*scale/2-0.02*_1,-dir,0,scale/2-burn-r/2]}
  rand(2..8).times do
    next if rand > (n-ti).fdiv(n)*2
    a=[0.2+ti*0.05,1].min
    sparks << [ball,-dir*(1-a)/2 + a * 0.5 * (1 + rand) * 536**rand.i, 1 + rand, (1-a)+0.5+rand]
  end
  sparks = sparks.flat_map{spark[*_1,1]}
  show[]
  sleep 0.1
end
