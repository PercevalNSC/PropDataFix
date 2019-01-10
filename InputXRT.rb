def ptrary(ary)
  len = ary.size
  i = 0
  puts "- length=#{len}\n"
  printf("[")
  while i < len do
    printf("%3.5f, ",ary[i])
    i += 1
  end
  printf("]")
  printf("\n")
end
def ptrstatus(radius,cord,thick,beta)
  puts "* radius\n"
  ptrary(radius)
  puts "* cord\n"
  ptrary(cord)
  puts "* thickness\n"
  ptrary(thick)
  puts "* beta\n"
  ptrary(beta)
  return;
end

desiradius = Array.new
desicord = Array.new
desithick = Array.new
desibeta = Array.new
ubody = Array.new
radius = 1660
thickper = 0.0912
File.open('input.txt') do |file|
  file.each_line do |labmen|
    single = labmen.chomp.split(' ')
    printf("%f %f %f %f\n",single[0].to_f,single[1].to_f,single[2].to_f,single[3].to_f)
    desiradius.push(single[0].to_f)
    desicord.push(single[1].to_f)
    desithick.push(single[1].to_f * radius * thickper)
    desibeta.push(single[2].to_f)
    ubody.push(single[3].to_f)
  end
end

ptrstatus(desiradius,desicord,desithick,desibeta)
