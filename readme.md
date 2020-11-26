#用于768x576的逐行扫描video转换成隔行扫描
PAL square pixel格式，输入给模块时钟 29.5MHz， 输出数据适中经过2分频。输出数据可以直接输出给ADV7393（29.5MHz）

这里只post出前仿真工程，fifo阉割掉。


##colorbar_gen_rgb565模块
除了产生的video timing可以用于重建时序，还能产生pixel的行列计数，包括可视区域行列计数。这里只用于interlacer模块之前，提供重建的时序和各行列计数。

##interlacer模块
工程化需要再添加一个dual clock fifo，出入口都是16bit位宽，深度2048。足够存储PAL/NTSC应用的两个行数据。

例如PAL的奇数场时，奇数行按29.5MHz写入fifo，而按14.75MHz读出fifo的数据；偶数场时，偶数行按29.5MHz写入fifo，按14.75MHz读出fifo，这样就实现了行的间隔化。

PAL的line number从1到625，奇数行比偶数行多1个。FIELD 信号，奇数场时输出为低， 奇数场时输出为高。

/HSYNC和/VSYNC输入同时发生低转换表示奇数场开始，当/HSYNC为高电平时，/VSYNC发生低转换表示偶数场开始。

## modelsim仿真
do0.do是功能仿真脚本

$ vsim &

然后在modelsim窗口执行

VSIM 1> do do0.do 

