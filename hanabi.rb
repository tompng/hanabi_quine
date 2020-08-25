chars = ' ▘▝▀▖▌▞▛▗▚▐▜▄▙▟█'
width=160
canvas = (width / 2).times.map { [0] * width }

g = 0.5i
scale = 4.0
stroke = ->(p, v, a, t) {
  v2 = v + a * t
  n = (width * ((v+v.real).rect+(v2+v2.real).rect).map(&:abs).max * t / scale / 2 + 1).ceil
  n.times {
    u = t * _1.fdiv(n - 1)
    q=p+v*u+a*u*u/2
    (0...width).cover?(x = (width / 2 + q.real / scale * width).round) &&
    (0...width/2).cover?(y = (width / 4 + q.imag / scale * width / 2).round) &&
    canvas[y][x] = 1
  }
}

spark = ->(p, v, lt, st, tt) {
  t = [tt, lt, st].min
  stroke[p,v,g,t]
  p+=v*t+g*t*t/2
  v+=g*t
  (t == lt)?
    []:
  (t == tt)?
    [[p, v, lt - t, st - t]]
  :
    (0..rand(4..9)).flat_map {
      spark[p, v/4 + 536 ** rand.i*(1 + rand)/2, (lt - t) / 2 + 0.4 * rand, 8, tt - t]
    }
}

sparks = []
(0..).each {|i|
  canvas.map { |l| width.times { l[_1] = 0 } }
  n = 200
  m = 40
  ti = i % (n+m)
  ti==0&&srand(0)
  t=[0,(3*n+2*m-3.0*ti)/m,1].sort[1]
  d=0.1-1i
  bt = [ti.fdiv(n),t*t*(3-2*t)].min
  c = bt*d + (ti > n ? g * (ti - n) ** 2 / 2 : 0)
  r = 0.1*[ti*0.05,1].min
  ir = (r / scale * width).ceil
  iy = (c.imag / scale * width / 2).ceil
  (iy-ir...iy+ir).each { |y|
    y < width/4 && (-2*ir..2*ir).each { |x|
      p = (x +y*2i)* scale / width
      canvas[width/4+y][width/2+x]=1 if (p-c).abs<r
    }
  }
  [-1,1].map{stroke[d*scale/2-0.02*_1,-d,0,scale/2-bt-r/2]}
  rand(2..8).times {
    a=[0.2+ti*0.05,1].min
    sparks << [c,-d*(1-a)/2 + a * 0.5 * (1 + rand) * 536**rand.i, 1 + 2 * rand, (1-a)+0.5+rand] if (rand < 2.0*(n-ti)/n)
  }
  sparks = sparks.flat_map{spark[*_1,1]}

  puts "\e[1;1H" + (0...width / 4).map{|j|
    (0...width / 2).map { |i|
      chars[4.times.sum {|k| canvas[2*j+k/2][2*i+k%2]<<k }]
    } * ''
  }*$/
  sleep 0.1
}
