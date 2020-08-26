require_relative './reed_solomon'
rs_code = File.read('./rs_solver.rb').split(/# [A-Z]+/)[1].delete(" \n")
hanabi_code = File.read('./hanabi.rb').delete(" \n")
expand_code = File.read('./rs_expander.rb').delete(" \n")
# puts ((32..128).map(&:chr)-(rs_code+hanabi_code).chars).join
p rs_code.size
p hanabi_code.size

header = <<~HEADER_CODE
  eval($a=%(n=0x00;->z{$h='eval%c$a=%%%c'%[40,40]+$a;$z=41.chr*2+'[$z=%@'+$z;eval((';'*8+z+';'*2).scan(/^.{8}|.{8}$/)*'')}
  ))[$z=%@
HEADER_CODE

side_code = rs_code + ';' + expand_code
p side_code.size, 47 * 16



puts header

eval header + '@]'
puts $h
puts $z


rs = ReedSolomon.new 12


OFFSET = 12
def coord(i, j)
  j<12?[i/2,2*j+i%2-12]:(a=((i*36+(j-12))*19%3384);[a/72,12+a%72])
end

innercode = 47.times.map {|i| '-' * 12 + 72.times.map {|j| (j-36)**2+(2*i-48)**2<24**2 ? rand(10) : (97+rand(26)).chr }.join + '-' * 12}
puts innercode

94.times { |i|
  s=(r=0..47).map { j, k = coord(i, _1); innercode[j][k] } * ''
  inflated = rs.inflate s[12..-1]
  s=(r=0..47).map { j, k = coord(i, _1); innercode[j][k] = inflated[_1] } * ''
}
original = innercode.map(&:dup)
puts innercode
650.times{
  line = innercode.sample
  line[rand line.size] = '█'
}
puts innercode
$z = innercode.map{'-'*8+_1+'-'*8}.join("\n")

rs = eval rs_code
restored = eval expand_code+';e'
puts restored
puts restored == original