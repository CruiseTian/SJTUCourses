# 计算机组成实验2 单周期CPU模块IO设计仿真

## 实验目的

1、在理解计算机5大组成部分的协调工作原理，理解存储程序自动执行的原理和掌握运算器、存储器、控制器的设计和实现原理基础上，掌握I/O端口的设计方法，理解I/O地址空间的设计方法。
2、通过设计I/O端口与外部设备进行信息交互。
3、通过设计并实现新的自定义指令拓展CPU功能，深入理解CPU对指令的译码、执行原理和实现方式。（选做）

## 实验过程

+ 首先新建一个项目`sc_cpuio`,将之前的代码添加进去
+ 首先根据要求，新建`sc_datamem.v,in_input.v和io_output.v`,并根据实验指导添加和修改代码
+ 新建`in_port.v,out_port.v,clk_and_mem_clk.v`和顶层文件`sc_cpuio.v`
+ `in_port.v`用来接收按键的输入，将小于32bit的输入转化为32位，代码大概如下：

![Snipaste_2020-05-22_15-18-51](http://figure.cruisetian.top/img/Snipaste_2020-05-22_15-18-51.png)

+  `out_port_seg.v` 将输出数据转成十进制并经过七段译码器输出到 LED，代码大概如下（译码器部分截不全）：

![Snipaste_2020-05-22_15-20-46](http://figure.cruisetian.top/img/Snipaste_2020-05-22_15-20-46.png)

+ `clk_and_mem_clk.v`作用是是采用一个 clk 作为主时钟输入，在内部给出二分频后作为 CPU 模块的工作时钟，并产生 mem_clk，用于对 CPU 模块内 含的存储器读写控制。主要代码如下：

![Snipaste_2020-05-22_15-23-29](http://figure.cruisetian.top/img/Snipaste_2020-05-22_15-23-29.png)

+ 其中最主要的是顶层文件`sc_cpuio.v`，在这个文件中，我们根据实验指导中的工程截图，将各个模块例化并连接，实现顶层布局，其中用到了上一次实验的`sc_computer_main.v`，由`sc_computer.v`更改而来，增加了输入输出端口的声明，由于并没有什么重要的更改，在这里就不展示，接下来展示顶层文件`sc_cpuio.v`的主要代码：

![Snipaste_2020-05-22_15-30-09](http://figure.cruisetian.top/img/Snipaste_2020-05-22_15-30-09.png)

+ （选做部分）增加了一条`nor`指令，function code定义为100111，主要更改了`alu.v`,`sc_cu.v`,和`sc_instmem.mif`文件（为了验证指令），更改主要部分如下：

**alu.v**:

![Snipaste_2020-05-22_15-35-35](http://figure.cruisetian.top/img/Snipaste_2020-05-22_15-35-35.png)

**sc_cu.v**:

![Snipaste_2020-05-22_15-36-19](http://figure.cruisetian.top/img/Snipaste_2020-05-22_15-36-19.png)

![Snipaste_2020-05-22_15-37-37](http://figure.cruisetian.top/img/Snipaste_2020-05-22_15-37-37.png)

**sc_instmem.mif**(注释部分没有修改)：

![Snipaste_2020-05-22_15-38-14](http://figure.cruisetian.top/img/Snipaste_2020-05-22_15-38-14.png)

## 结果分析

### 增加指令前的结果

增加指令前的结果中，HEX0和HEX1组成了“被加数”的数码管，HEX2和HEX3组成了“加数”的数码管，HEX4和HEX5组成了“和”的数码管，根据下面寄存器显示的结果，4号和5号寄存器相加得到的结果和6号寄存器中的值相同，说明结果正确，结果图如下：

![Snipaste_2020-05-22_13-19-54](http://figure.cruisetian.top/img/Snipaste_2020-05-22_13-19-54.png)

**增加指令后的结果**

增加指令前的结果中，HEX0和HEX1，HEX2和HEX3组成了或非操作的来源数的数码管，HEX4和HEX5组成了展示或非结果的数码管，根据下面寄存器显示的结果，4号和5号寄存器或非得到的结果和6号寄存器中的值相同，说明结果正确，结果图如下：

![Snipaste_2020-05-22_14-21-02](http://figure.cruisetian.top/img/Snipaste_2020-05-22_14-21-02.png)