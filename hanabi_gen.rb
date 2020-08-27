require_relative './reed_solomon'
rs_code = File.read('./rs_solver.rb').split(/# [A-Z]+/)[1].delete(" \n")
hanabi_code = File.read('./hanabi.rb').lines.drop(2).join.delete(" \n")
expand_code = File.read('./rs_expander.rb').delete(" \n")
# puts ((32..128).map(&:chr)-(rs_code+hanabi_code).chars).join
p rs_code.size
p hanabi_code.size
p ((32...127).map(&:chr)-hanabi_code.chars).join
p (hanabi_code.chars-(32...32+64).map(&:chr)).uniq.sort.join

# frame 17 or 46

header = <<~HEADER_CODE
  ;+eval($h=%(ti=0x00;->z{$z=z.lines[1..];$z[-1]+='`]';eval((z+';;').scan(/^.{10}|.{10}$/).join)}))[%`
HEADER_CODE

side_code = rs_code + ';' + expand_code
p side_code.size, 39 * 22


puts header

eval header + ';;;;;;;;;;;;;;;;123`]'
puts $hanabi
puts $z




FIXES = 12
rsobj = ReedSolomon.new FIXES
def coord(i, j)
  (i+j*29)%80
end

hanabi_chars = hanabi_code.chars+[';']*1000
template = File.read('./template.txt').lines
innercode = (39-FIXES).times.map do |y|
  80.times.map do |x|
    (template[y]||'')[x] == '#' ? ' ' : hanabi_chars.shift
  end.join
end + (['-'*80]*FIXES).map(&:dup)
# innercode = (hanabi_code+';'+' '*10000).chars.each_slice(80).take(39-FIXES).map(&:join)+(['-'*80]*FIXES).map(&:dup)
p spaces: innercode.join.count(' ')

outs = []
80.times { |i|
  s = (0...39).map { innercode[39-1-_1][coord(i, _1)] } * ''
  inflated = rsobj.inflate(s[FIXES..].tr('{|}~', '"#!\\')).tr('"#!\\', '{|}~')
  outs << inflated
  (0...39).each { innercode[39-1-_1][coord(i, _1)] = inflated[_1] }
}
eval_code = "eval$z[0,#{39-FIXES}].map{_1[10,80].split}*''"
side_code_chars = [rs_code, expand_code, eval_code].join(';').chars
zwas = innercode.map{'▄'*10+_1+'▄'*10}
zwas[-1][-2,2] = '`]'
zwas=zwas.map { _1.gsub(/▄/) { side_code_chars.shift || ';' } }.join("\n").lines
$z = zwas.map(&:dup)
p side_code_chars.size
200.times{
  line = $z.sample
  line[rand(10...10+80)] = '█'
}
puts
restored = eval rs_code+';'+expand_code
puts
puts $z
puts zwas == $z
File.write 'output.rb', header + zwas.join
# binding.irb