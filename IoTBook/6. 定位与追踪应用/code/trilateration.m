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

