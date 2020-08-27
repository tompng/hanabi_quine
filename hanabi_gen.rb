require_relative './reed_solomon'
rs_code = File.read('./rs_solver.rb').split(/# [A-Z]+/)[1].delete(" \n")
hanabi_code = File.read('./hanabi.rb').lines.drop(2).join.delete(" \n")
expand_code = File.read('./rs_expander.rb').delete(" \n")
# puts ((32..128).map(&:chr)-(rs_code+hanabi_code).chars).join
p rs_code.size
p hanabi_code.size
p ((32...127).map(&:chr)-hanabi_code.chars).join
p (hanabi_code.chars-(32...32+64).map(&:chr)).uniq.sort.join



# $h='eval(a=%('+a;
header = <<~HEADER_CODE
  eval($h=%(0x00;->z{$z=(41.chr*2+'[$z=++%`'+$z).lines;eval((';'*10+z+';;').scan(/^.{10}|.{10}$/)*'')}
  ))[$z=++%`
HEADER_CODE



side_code = rs_code + ';' + expand_code
p side_code.size, 39 * 22



puts header

eval header + ';;;;;;;;;;;;;;;;[]`]'
puts $h
puts $z


rsobj = ReedSolomon.new 12


OFFSET = 12
def coord(i, j)
  (i+j*9)%80
end

innercode = (hanabi_code+';'+' '*10000).chars.each_slice(80).take(39-12).map(&:join)+(['-'*80]*12).map(&:dup)
p spaces: innercode.join.count(' ')

outs = []
80.times { |i|
  s = (0...39).map { innercode[39-1-_1][coord(i, _1)] } * ''
  inflated = rsobj.inflate(s[12..].tr('{|}~', '"#!\\')).tr('"#!\\', '{|}~')
  outs << inflated
  (0...39).each { innercode[39-1-_1][coord(i, _1)] = inflated[_1] }
}
eval_code = "eval$z[0,#{39-12}].map{_1[10,80].split}*''"
side_code_chars = [rs_code, expand_code, eval_code].join(';').chars
zwas = innercode.map{'▄'*10+_1+'▄'*10}
zwas[0]=header.lines[1].strip+zwas[0][10..]
zwas[-1][-2,2] = '`]'
zwas=zwas.map { _1.gsub(/▄/) { side_code_chars.shift || ';' } }.join("\n").lines
$z = zwas.map(&:dup)
# puts zwas
p side_code_chars.size

200.times{
  line = $z.sample
  line[rand(10...10+80)] = '█'
}
puts
# puts $z
restored = eval rs_code+';'+expand_code
# eval_code = "eval($z.map{_1[10,80].delete(32.chr)}.take(39-12)*'')"
# eval [rs_code, expand_code, eval_code].join(';')
puts
# puts $z
puts zwas == $z
File.write 'output.rb', header.lines[0] + zwas.join
# binding.irb