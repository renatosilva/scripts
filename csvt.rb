i = File.open(ARGV[0], 'r')  
o = File.open(ARGV[1], 'w')

i.each_line do |line|
    nl = ARGV[2].dup
    r = line.gsub(/\n/, '').split(";")
    r.each_with_index { |c, n| nl.gsub!(/\$#{n + 1}/, c) }
    o.puts(nl)
end
