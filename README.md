# PropDataFix
Xrotorの設計データを制作用に修正するRubyプログラム

開発者：U.E.C.wings19プロペラ設計

プロペラは実制作上一定長さの区間に分けて作成しますが、
Xrotorで出てくる設計データは偏在していて、
これを補完するプログラムが必要となります。
また、無次元半径で表されているために、
これを実際の長さに合わせるとともに翼厚の計算も行います。

使用法：（初期時のためのちのち変わってるかも）

1.Xrotorの設計ファイル（特に拡張子がない）から「radius,cord,beta,ubody」の列をコピーする。デフォルトでは30点で計算しているので、変えてなければ30点ある。

2.ExcelにコピーしてTRIMコマンドで余計なスペースを削除する。現状、４つのパラメータの値のみがスペース１つを挟んで並んだ状態でしか認識しないはず。

3.スペースを削除したデータをコピーし、適当なテキストファイルに貼り付ける。

4.コマンドラインから「$ruby DataFixProgram.rb < input.txt」として実行する。実行時結構な量のログデータ出すので、「>output.txt」として他のファイルに移すのがよさげ。

5.ハブ 100mm、区間 52mmで直されたデータを「fixed_data.txt」として出力する。他のデータを読み込ませると上書きされるので、作ったあとは名前を変えましょう。
 
詳しいことは後ほど。

2019/1/10 @PercevalNSC
