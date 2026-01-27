
# 三边定位算法
在测距的基础上，可以实现对设备或者人的定位。在本节我们将介绍三边定位算法，利用该算法，我们可以从测距结果中计算出目标设备的位置。

## 三边定位基本原理

三边定位算法（Trilateration）的基本原理如下图所示，假设我们要定位图中电子标签（红色天线），图中各基站的位置为已知。在计算标签位置之前，我们先通过上一章介绍的测距方法，得到各基站到标签的距离$d_i$。根据测距结果，我们以基站的位置为圆心，做半径为$d_i$的圆。通过搜索空间中多个基站处绘制圆弧的焦点，我们可以最终求出标签的位置。下图展示了已知基站1，2，3的坐标以及标签到基站的距离，通过三圆求交的方法得到标签的位置。

<center>
<img src="./fig/三边定位.png" width=600px>
</center>

<center>
<div style="color:orange; border-bottom: 1px solid #d9d9d9;
display: inline-block;
color: #999;
padding: 2px;">图. 三边定位基本原理</div>
</center>

三边定位搜索圆弧交点的过程实际上等价于求解方程组：假设三个基站的坐标已知，分别记为$(x_1,y_1)$, $(x_2,y_2)$, $(x_3,y_3)$。待定位标签的坐标记为$(x,y)$，到三个网关的距离分别为$d_1$, $d_2$, $d_3$。则我们可以联立方程组：

$$
\left\{\begin{matrix}d_1=\sqrt{(x_1-x)^2+(y_1-y)^2}\\d_2=\sqrt{(x_2-x)^2+(y_2-y)^2}\\d_3=\sqrt{(x_3-x)^2+(y_3-y)^2} \end{matrix}\right.
$$

通过求解上述方程组，可以得到标签坐标。上述三边定位算法可以很容易地推广到三维场景。在进行三维定位时，我们只需要在测量出基站到节点的距离后，在每个基站处用圆球去建模，即以基站坐标和球心做半径为$d$的圆球，标签一定位于球面的某个点上。因此我们通过求多个球面的唯一交点，即可确定标签在三维空间中的位置。


三边定位的原理比较简单，这也是最常用的定位算法了。但在实际系统中实现这一算法仍然面临许多困难和挑战。考虑到测距误差的存在，以不同基站为中心绘制的圆弧或球面可能不交于一点。实际上，由于测距算法只能得到实际距离在一定误差范围内的结果，给定一个基站坐标，我们通常只能假设标签在以基站为中心的、具有一定宽度的圆环范围内。这样一来，如何设计坐标计算方法以最小化定位误差就成了实际系统部署时必须考虑的问题。

除此之外，在实际环境中，基站的数量可能多于三个，当基站数量多于坐标维度时，如何选择最优基站也成为在定位时必须要解决的问题。

在实现时，为了解决测距误差对定位的影响，我们通常采用最优化二乘法的方法求解目标标签的坐标。不妨假设已知的基站坐标为$P_{ai} \ (i=1,2,3...N)$，$N$为基站数量。待求解的目标标签坐标为$P_t$。那么我们可以计算理论上标签到各个基站的距离$d_i$

$$
d_i = \|P_t-P_{ai}\|
$$

同时我们知道测量得到的标签到各个基站的距离$\hat{d}_{i}$，这样我们就可以根据已有的信息，把理论值和测量值最接近的位置$P$作为最后的定位结果：

$$
P_t = \underset{p}{argmin} \sum_{i=1}^N (d_i-\hat{d}_i)^2
$$

下面我们展示一种解上述最优化方程的解法示例。由于标签位置$(x, y)$在基站位置$(x_i,y_i)$的定位圆的交点上，标签到各基站测量对应的距离分别为$d_i$。最基本的做法是解下面的方程组(一共n个基站)直接得到标签坐标：

$$
\begin{cases}
    (x-x_1)^2+(y-y_1)^2=d_1^2\\
    \vdots\\
    (x-x_n)^2+(y-y_n)^2=d_n^2
\end{cases} \tag{8}
$$

但由于测量误差的存在，基于基站的定位圆并不会刚好交于一点。因此，在计算时，我们需要对其进行近似求解。常见方法有加权法、最小二乘法、质心法等。这里我们使用最小二乘法进行计算，在式(8)的基础上，我们将前n-1个方程减去第n个方程，得到线性化方程：$AX=b$。其中：

$$
A=\left[
    \begin{matrix}
        2(x_1-x_n) & 2(y_1-y_n)\\
        \vdots  &  \vdots  \\
        2(x_{n-1}-x_n) & 2(y_{n-1}-y_n)
    \end{matrix}
\right],
$$

$$
b=\left[
    \begin{matrix}
        x_1^2-x_n^2+y_1^2-y_n^2+d_n^2-d_1^2\\
        \vdots \\
        x_{n-1}^2-x_n^2+y_{n-1}^2-y_n^2+d_n^2-d_{n-1}^2
    \end{matrix}
\right]
$$

则利用最小二乘法可以解得：

$$
X=(A^TA)^{-1}A^Tb \tag{9}
$$

上述最小二乘解法的MATLAB实现代码如下

```matlab
nodeNumber = 3;   %定位信标的数量
nodeList = [0, 0; 2, 0; 1, 1.732];   %三个定位信标的坐标
disList = [1.155, 1.155, 1.155];    %定位目标点到三个定位信标的距离

A = [];
B = [];
xn = nodeList(nodeNumber, 1);
yn = nodeList(nodeNumber, 2);
dn = disList(nodeNumber);
for i=1:nodeNumber-1
    xi = nodeList(i, 1);
    yi = nodeList(i, 2);
    di = disList(i);
    A = [A; 2 * (xi - xn), 2 * (yi - yn)];
    B = [B; xi * xi + yi *yi - xn * xn - yn * yn + dn * dn - di * di];
end    %计算线性方程组的参数A和B

X = inv(A'*A)*A'*B   %根据最小二乘法公式计算结果X
```

上述代码中，nodeList表示基站的位置坐标，nodeNumber表示基站的数量，disList表示标签到各基站的距离。分别求得A和B以后，根据式(9)即可求得定位点的坐标X。

在实际应用中，我们需要根据实际情况选择合适的方法，可以设计不同的方法代替最小二乘法实现位置的近似计算，实现更高的定位精度。某些场景下可能无法实现对方程的直接求解，或是直接求解方程很困难，此时可以使用数值方法进行近似求解，常见的方法有梯度下降法等。

<!-- （延伸阅读：https://github.com/megagao/IndoorPos） -->

## 参考文献

[1] IEEE 802 Working Group et al. 2011. Ieee standard for local and metropolitan
area networks—Part 15.4: Low-rate wireless personal area networks (lr-wpans).
IEEE Std 802 (2011), 4–2011.

[2] Dries Neirynck, Eric Luk, and Michael McLaughlin. 2016. An alternative doublesided
two-way ranging method. In 2016 13th workshop on positioning, navigation
and communications (WPNC). IEEE, 1–4.

[3] "IEEE Standard for Information technology–Telecommunications and information
exchange between systems Local and metropolitan area networks–Specific
requirements - Part 11: Wireless LAN Medium Access Control (MAC) and Physical
Layer (PHY) Specifications". "IEEE Std 802.11-2016 (Revision of IEEE Std
802.11-2012)", pages 1–3534, Dec 2016.

[4] Benjamin Kempke, Pat Pannuto, Bradford Campbell, and Prabal Dutta. 2016. Surepoint:
Exploiting ultra wideband flooding and diversity to provide robust, scalable,
high-fidelity indoor localization. In Proceedings of the 14th ACM Conference on
Embedded Network Sensor Systems CD-ROM. 137–149.

[5] https://github.com/megagao/IndoorPos
