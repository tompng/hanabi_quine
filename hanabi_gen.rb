require_relative './reed_solomon'
rs_code = File.read('./rs_solver.rb').split(/# [A-Z]+/)[1].delete(" \n")
hanabi_code = File.read('./hanabi.rb').delete(" \n")
expand_code = File.read('./rs_expander.rb').delete(" \n")
# puts ((32..128).map(&:chr)-(rs_code+hanabi_code).chars).join
p rs_code.size
p hanabi_code.size
p ((32...127).map(&:chr)-hanabi_code.chars).join
p (hanabi_code.chars-(32...32+64).map(&:chr)).uniq.sort.join


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


rsobj = ReedSolomon.new 12


OFFSET = 12
def coord(i, j)
  j<12?[i/2,2*j+i%2-12]:(a=((i*36+(j-12))*19%3384);[a/72,12+a%72])
end


innercode = (hanabi_code+';'+10000.times.map{rand(10)}.join).chars.each_slice(72).take(47).map { '-' * 12 + _1.join + '-' * 12 }


puts innercode

94.times { |i|
  s = (0..47).map { j, k = coord(i, _1); innercode[j][k] } * ''
  inflated = rsobj.inflate(s[12..-1].tr('{|}', '"#!')).tr('"#!', '{|}')
  (0..47).each { j, k = coord(i, _1); innercode[j][k] = inflated[_1] }
}
original = innercode.map(&:dup)
puts innercode
640.times{
  line = innercode.sample
  line[rand line.size] = '█'
}
puts innercode
$z = innercode.map{'-'*8+_1+'-'*8}.join("\n")

restored = eval rs_code+';'+expand_code+';e'
eval_code = "eval(e.map{_1[12,72].delete(32.chr)}*'')"
side_code = eval [rs_code, expand_code, eval_code].join(';')
puts restored
puts restored == original
