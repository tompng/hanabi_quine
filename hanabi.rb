$h ||= '-'*114+$/;
$z ||= (['-'*9+'*'*96+'-'*9] * 47).join($/).lines;

charactors = 32.chr;
15.times{ charactors += (9600+0x23f92721abefccb03b8[_1*5,5]).chr 'utf-8' };
width = 48*4;
canvas = (width / 2).times.map { [0] * width };
g = 0.5i;
scale = 4.0;
stroke = -> p, v, a, t {
  v2 = v + a * t;
  n = (width * ((v+v.real).rect+(v2+v2.real).rect).map(&:abs).max * t / scale / 2 + 1).ceil;
  n.times {
    u = t * _1.fdiv(n - 1);
    q=p+v*u+a*u*u/2;
    (0...width).cover?(x = (width / 2 + q.real / scale * width).round) &&
    (0...width/2).cover?(y = (width / 4 + q.imag / scale * width / 2).round) &&
    canvas[y][x] = 1
  }
};

spark, *sparks = -> p, v, lt, st, tt {
  stroke[p, v, g, t = [tt, lt, st].min];
  p+=v*t+g*t*t/2;
  v+=g*t;
  (t == lt)?
    []:
  (t == tt)?
    [[p, v, lt - t, st - t]]
  :
    (0..rand(4..9)).flat_map {
      spark[p, v/4 + 536 ** rand.i*(1 + rand)/2, (lt - t) / 2 + 0.4 * rand, 8, tt - t]
    }
};

(0..).each {|i|
  canvas.map { |l| width.times { l[_1] = 0 } };
  stp = 200;
  ti = i % (stp + m = 40);
  ti==0&&srand(0);
  t=[0,(3*stp+2*m-3.0*ti)/m,1].sort[1];
  d=0.1-1i;
  bt = [ti.fdiv(stp),t*t*(3-2*t)].min;
  c = bt*d + ((ti > stp) ? g * (ti - stp) ** 2 / 2 : 0);
  r = 0.1*[ti*0.05,1].min;
  ir = (r / scale * width).ceil;
  iy = (c.imag / scale * width / 2).ceil;
  (iy-ir...iy+ir).each { |y|
    y < width/4 && (-2*ir..2*ir).each { |x|
      p = (x +y*2i)* scale / width;
      canvas[width/4+y][width/2+x]=1 if (p-c).abs<r
    }
  };
  [-1,1].map{stroke[d*scale/2-0.02*_1,-d,0,scale/2-bt-r/2]};
  rand(2..8).times {
    sparks << [c,-d*(1-a=[0.2+ti*0.05,1].min)/2 + a * 0.5 * (1 + rand) * 536**rand.i, 1 + 2 * rand, (1-a)+0.5+rand] if (rand < 2.0*(stp-ti)/stp)
  };
  sparks = sparks.flat_map{spark[*_1,1]};
  sp = 32.chr;
  puts '' << 27 << '[1;1' << 72 << $h << (0...width / 4 - 1).map {|j|
      a = sp * 9 + (0...width / 2).map { |i|
        charactors[4.times.sum {|k| canvas[2*j+k/2][2*i+k%2]<<k }]
      } * '' + sp * 9;
      (0..113).map { (a[_1] == sp) ? $z[j][_1] : a[_1] } * ''
    } * $/ + 96.chr+']'
  ;
  sleep(0.1)
}
