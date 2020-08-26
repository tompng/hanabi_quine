BITS = 6
BASE = 0b1000011
class ReedSolomon
  BITS = 6
  BASE = 0b1000011
  AN = [1]
  IAN = [nil]

  (1...(1 << BITS)).map do |i|
    y = AN[i - 1] * 2
    y ^= BASE if y >= 1 << BITS
    AN[i] = y
    IAN[y] = i
  end

  def initialize(fixes)
    @fixes = fixes
    @gx = [1]
    fixes.times do |i|
      xg = [0, *@gx]
      ag = @gx.map { |v| self.class.mult(v, AN[i]) } + [0]
      @gx = xg.zip(ag).map { _1 ^ _2 }
    end
  end

  def self.mult(a, b)
    o = 0
    BITS.times do |i|
      o ^= a[i] * b << i
    end
    (o.bit_length - 1).downto(BITS) do |i|
      o ^= BASE << (i - BITS) if o[i] == 1
    end
    o
  end

  def mod_g(data)
    while data.size >= @gx.size
      a = data.last
      (1..@gx.size).each do |i|
        data[-i] ^= self.class.mult a, @gx[-i]
      end
      data.pop
    end
    data
  end

  def inflate(input)
    data = input.chars.map { _1.upcase.ord-32 }
    encoded = mod_g([0] * @fixes + data) + data
    encoded.map { (32 + _1).chr.downcase }.join
  end

  def restore(input)
    error_indices = []
    data = input.chars.map.with_index do |c, i|
      if c.ord < 127
        c.upcase.ord - 32
      else
        error_indices << i
        0
      end
    end
    num_errors = error_indices.size
    ss = []
    mat = []
    num_errors.times.map do |i|
      si = 0
      data.each_with_index do |v, j|
        si ^= self.class.mult v, AN[i * j % ((1 << BITS) - 1)]
      end
      ss << si
      mat << error_indices.map do |j|
        AN[i * j % ((1 << BITS) - 1)]
      end
    end
    (num_errors - 1).times do |i|
      inv = AN[(1 << BITS) - 1 - IAN[mat[i][i]]]
      (i + 1...num_errors).each do |j|
        a = self.class.mult mat[j][i], inv
        (i...num_errors).each do |k|
          mat[j][k] ^= self.class.mult a, mat[i][k]
        end
        ss[j] ^= self.class.mult a, ss[i]
      end
    end

    (num_errors - 1).downto(0) do |i|
      inv = AN[(1 << BITS) - 1 - IAN[mat[i][i]]]
      (0...i).each do |j|
        a = self.class.mult mat[j][i], inv
        ss[j] ^= self.class.mult ss[i], a
        mat[j][i] ^= self.class.mult mat[i][i], a
      end
      ss[i] = self.class.mult ss[i], inv
    end
    output = input.dup
    ss.zip error_indices do |code, i|
      output[i] = (code + 32).chr.downcase
    end
    output
  end
end

srand 0
size = 50
fixes = 20
data = ('hello world'.chars.cycle).take(size - fixes).join
rs = ReedSolomon.new fixes
encoded = rs.inflate data
error_indices = (0...size).to_a.sample rand(fixes / 2..fixes)
masked = encoded.dup.tap do |s|
  error_indices.each { s[_1] = '█' }
end

p data
p encoded
p masked
p rs.restore(masked)
