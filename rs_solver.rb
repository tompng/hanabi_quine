INPUT = "m██q2)&6'nn█3█f█7███he█████or██h█llo█wor█d█e█lo wo"
ANSWER = "m_:q2)&6'nn43nfx7_wghello worldhello worldhello wo"
# SOLVER
rs = ->s,b=[1],*c{
  63.times { |i|
    j = b[i] << 1;
    j > 63 && j ^= 67;
    c[b[i + 1] = j] = 62 - i
  };

  ml = ->i, j, k=0{
    6.times { k ^= i[_1] * j << _1 };
    (k.bit_length - 1).downto(6) { k[_1] == 1 && k ^= 67 << (_1 - 6) };
    k
  };

  ix = [];
  cd = s.chars.map.with_index {
    _1.ord < 127 ? _1.upcase.ord - 32 : (ix << _2; 0)
  };
  v = [];
  m = (0...n = ix.size).map { |i|
    j = 0;
    cd.each_with_index { j ^= ml[_1, b[i * _2 % 63]] };
    v << j;
    ix.map { b[i * _1 % 63] }
  };

  (n - 1).times { |i|
    k = b[c[m[i][i]]];
    (l = i+1...n).each { |j|
      a = ml[m[j][i], k];
      l.each { m[j][_1] ^= ml[a, m[i][_1]] };
      v[j] ^= ml[a, v[i]]
    }
  };

  (n - 1).downto(0) { |i|
    j = b[c[m[i][i]]];
    i.times {
      k = ml[m[_1][i], j];
      v[_1] ^= ml[v[i], k]
    };
    v[i] = ml[v[i], j]
  };
  v.zip(ix){s[_2]=(_1+32).chr.downcase}
}
# TEST
output = INPUT.dup
rs[output]
p output, output == ANSWER
