code = File.read 'output.rb'
$code_begin = code.lines[0].split(/0x/)[0]
$code_end = code.lines[-1].strip[-10,10]

def idnt(x); x; end
def restore(frame)
  eval frame.gsub(/eval\$z/, 'idnt$z')  
end
$answer = restore code

def each_frame
  io = IO.popen('ruby output.rb')
  s = ''
  loop do
    s << io.readpartial(1024)
    if (idx = s.index $code_begin)
      s = s[idx..]
    end
    if (idx = s.index $code_end)
      idx2 = idx + $code_end.size
      yield s[0..idx2].strip.force_encoding('utf-8')
      s = s[idx2..]
    end
  end
end
n = 0
errors = []
frames = []
each_frame { |frame|
  number = frame.scan(/0x[0-9a-f]{2}/)[0].to_i(16)
  frames[number] = frame
  if $answer == restore(frame)
    p [number, :ok]
  else
    p error: number
    errors << number
  end
  n += 1
  break if n == 256
}
if errors.empty?
  p :all_ok
else
  p errors: errors
end

binding.irb
