#input ary,print its length and elements
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
#input 4 ary, and print them.
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
#change thick rate due to section.
#thick rate means thick / cord at 1 /4 chord.
#when section is under change point, use rate1. else, use rate2.
#futere: Though select two rate, return rate as linear from two rate
def select_thick_rate(thickrate1,thickrate2,section_change_thickrate,i)
  if i < section_change_thickrate then
    return thickrate1
  else
    return thickrate2
  end
end

#main func

#######################
#designed brade data
radius = 1608
hub = 100
section_length = 52
thickrate1 = 0.149
thickrate2 = 0.0918
section_change_thickrate = 0
error_hub = 10
#######################
#t/c at 1/4 chord
#dae51 = 9.24%
#sd7037 = 9.18%
#geminism = 14.9%
#######################

#配列宣言
#desiがついてるのがXrotorの設計データ読み込み配列。ついてないのが出力用配列。
#Ubodyは使わないです。
desiradius = Array.new
desicord = Array.new
desithick = Array.new
desibeta = Array.new
ubody = Array.new

section = Array.new
cord = Array.new
thick = Array.new
beta = Array.new

puts "thickrate2:#{thickrate2}"

#designed brade dataでの入力チェック
#致命的なエラーのみチェックして、アウトならreturn
flag = 0
if (radius - hub) % section_length != 0 then
  flag = 1
end
if thickrate1 > 1 || thickrate2 > 1then
  flag = 1
end

if flag != 0 then
  puts "input failed\n Please check input data"
  return;
end

#input data from file
#input.txtから値を読み込んでXrotor設計データ配列に渡します。ついでに変数nで列の数も数えてる。
#ファイルから１行読んでlineへ渡し,chompで改行記号削除、splitでスペースごとを要素とした配列にして各配列にsingle[]で取り出して型変換して配列に格納してます。
n = 0
File.open('input.txt') do |file|
  file.each_line do |line|
    thickper = select_thick_rate(thickrate1,thickrate2,section_change_thickrate,n)
    single = line.chomp.split(' ')
    #printf("%f %f %f %f\n",single[0].to_f,single[1].to_f,single[2].to_f,single[3].to_f)
    desiradius.push(single[0].to_f)
    desicord.push(single[1].to_f)
    desithick.push(single[1].to_f * radius * thickper)
    desibeta.push(single[2].to_f)
    ubody.push(single[3].to_f)
    n += 1
  end
end

#Xrotor設計データの出力。デバッグ用。
puts "---design status---"
ptrstatus(desiradius,desicord,desithick,desibeta)
puts "-------------------"


#section set
#入力した区間長さをもとにリブを作成する区間の作成。ハブの長さに区間長さを足していき、ペラ端になるまで要素を作成します。
i = hub
while i <= radius do
  section.push(i)
  i += section_length
end

#区間の確認
puts "---section---"
p section
puts "-------------------"

#設計ペラ根データの確認
#ハブ位置と設計データの１つ目（一番根元）の差がerror_hubより大きければ、補完を行います。以下であれば根元のデータを採用します。
#30点では10mm以上差が出ます。60だと出なかったような。ログみればどっちでやっているかわかります。
if(desiradius[0] * radius - hub).abs > error_hub then
  puts "-----------------------------"
  puts "Waring:Too large radius in hub"
  puts "Calculate thick at hub by linear calculation from next section"
  printf("section[0]:%d\n",desiradius[0] * radius)
  puts "-----------------------------"
  thickper = select_thick_rate(thickrate1,thickrate2,section_change_thickrate,0)
  rs = section[0]
  r1 = desiradius[0]
  r2 = desiradius[1]
  c1 = desicord[0]
  c2 = desicord[1]
  b1 = desibeta[0]
  b2 = desibeta[1]
  cs = (c2 - c1)/(r2 - r1) * (rs - r1 * radius) + c1 * radius
  bs = (b2 - b1)/((r2 - r1) * radius) * (rs - r1 * radius) + b1
  cord.push(cs)
  thick.push(cs * thickper)
  beta.push(bs)
else
  puts "-----------------------------"
  puts "Use designed radius[0] as radius at hub "
  printf("section[0]:%d\n",desiradius[0] * radius)
  puts "-----------------------------"
  thickper = select_thick_rate(thickrate1,thickrate2,section_change_thickrate,0)
  cord.push(desicord[0] * radius)
  thick.push(desicord[0] * radius * thickper)
  beta.push(desibeta[0])
end

#区間数計算
numbersection = (radius - hub)/section_length

#Xrotor設計データから区間ごとに補完を行います。
#根元（０番）は行なったので１番から。
#ある区間について設計半径が区間より大きくなるまで設計半径を探し、その1個小さい設計半径のデータで一次式を作ります。これに区間を代入して、その区間での翼弦長と取り付け角を求めます。
#設計データは必ずペラ半径より小さくなるので、最後の区間は計算されません。
i = 1
while i < (numbersection) do
  j = 0
  rs = section[i]
  while (rs > desiradius[j] * radius) do
    j += 1
  end
  thickper = select_thick_rate(thickrate1,thickrate2,section_change_thickrate,i)
  #Linear interpolation
  r1 = desiradius[j-1]
  r2 = desiradius[j]
  c1 = desicord[j-1]
  c2 = desicord[j]
  b1 = desibeta[j-1]
  b2 = desibeta[j]
  cs = (c2 - c1)/(r2 - r1) * (rs - r1 * radius) + c1 * radius
  bs = (b2 - b1)/((r2 - r1) * radius) * (rs - r1 * radius) + b1
  cord.push(cs)
  thick.push(cs * thickper)
  beta.push(bs)
  i += 1
end

#ペラ端。翼弦長・厚さ０、角度は設計データの端。
cord.push(0)
thick.push(0)
beta.push(desibeta[n-1])

#修正データの表示。デバッグよう。
puts "---fixed status---"
ptrstatus(section,cord,thick,beta)
puts "-------------------"

#output to file
#「fixed_data.txt」に修正データを出力します。
#ファイルのデータは扱いやすいようスペース１つで区切られてますが、ログには整形した状態で出力されます。参考にどうぞ。
File.open("fixed_data.txt","w"){|file|
  i = 0
  file.puts("radius/chord/thick/beta")
  puts("radius/chord/thick/beta")
  while i <= numbersection do
    file.printf("%d %.2f %.2f %.2f\n",section[i],cord[i],thick[i],beta[i])
    #表示用整形表示
    printf("%5d %6.2f %5.2f %5.2f\n",section[i],cord[i],thick[i],beta[i])
    i += 1
  end
}
