BITS = 6
BASE = 0b1000011
FIXES = 20
SIZE = 50
an = [1]
ian = [nil]
(1...(1 << BITS)).map do |i|
  y = an[i - 1] * 2
  y ^= BASE if y >= 1 << BITS
  an[i] = y
  ian[y] = i
end

def mult(a, b)
  o = 0
  BITS.times do |i|
    o ^= a[i] * b << i
  end
  (o.bit_length - 1).downto(BITS) do |i|
    o ^= BASE << (i - BITS) if o[i] == 1
  end
  o
end

gx = [1]
FIXES.times do |i|
  xg = [0, *gx]
  ag = gx.map { |v| mult(v, an[i]) } + [0]
  gx = xg.zip(ag).map { _1 ^ _2 }
end
G = gx

def mod_g(data)
  while data.size >= G.size
    a = data.last
    (1..G.size).each do |i|
      data[-i] ^= mult a, G[-i]
    end
    data.pop
  end
  data
end
data = ('hello world' * 100).chars.take(SIZE - FIXES).map { _1.upcase.ord-32 }
encoded = mod_g([0] * FIXES + data) + data

p encoded, encoded.map { (32+_1).chr.downcase }.join
num_errors = FIXES - 0
error_indices = (0...SIZE).to_a.sample(num_errors)
data2 = encoded.dup
error_indices.each { data2[_1] = 0 }

ss = []
mat = []
num_errors.times.map do |i|
  si = 0
  data2.each_with_index do |v, j|
    si ^= mult v, an[i * j % ((1 << BITS) - 1)]
  end
  ss << si
  mat << error_indices.map do |j|
    an[i * j % ((1 << BITS) - 1)]
  end
end

answer = error_indices.map { encoded[_1] }
p answer

(num_errors-1).times do |i|
  inv = an[(1 << BITS) - 1 - ian[mat[i][i]]]
  (i+1...num_errors).each do |j|
    a = mult mat[j][i], inv
    (i...num_errors).each do |k|
      mat[j][k] ^= mult a, mat[i][k]
    end
    ss[j] ^= mult a, ss[i]
  end
end

(num_errors-1).downto(0) do |i|
  inv = an[(1 << BITS) - 1 - ian[mat[i][i]]]
  (0...i).each do |j|
    a = mult mat[j][i], inv
    ss[j] ^= mult ss[i], a
    mat[j][i] ^= mult mat[i][i], a
  end
  ss[i] = mult ss[i], inv
end

p ss
