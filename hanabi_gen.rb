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
  eval($a=%(->z{n=0x00;$h='eval($a=%('+$a;$z=('))[$z=%@'+$z).lines;eval((';'*8+z+';'*2).scan(/^.{8}|.{8}$/)*'')}
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

94.times { |i|
  s = (0..47).map { j, k = coord(i, _1); innercode[j][k] } * ''
  inflated = rsobj.inflate(s[12..-1].tr('{|}', '"#!')).tr('"#!', '{|}')
  (0..47).each { j, k = coord(i, _1); innercode[j][k] = inflated[_1] }
}
eval_code = "eval(e.map{_1[12,72].delete(32.chr)}*'')"
side_code_chars = [rs_code, expand_code, eval_code].join(';').chars
$z = innercode.map{'▄'*9+_1+'▄'*9}.join("\n").gsub(/▄/){side_code_chars.shift || ';'}.lines
p side_code_chars.size


zwas = $z.map(&:dup)
640.times{
  line = $z.sample
  line[rand(9...9+96)] = '█'
}
puts zwas
puts $z
restored = eval rs_code+';'+expand_code
# eval_code = "eval(e.map{_1[12,72].delete(32.chr)}*'')"
# eval [rs_code, expand_code, eval_code].join(';')
puts $z
puts zwas == $z
