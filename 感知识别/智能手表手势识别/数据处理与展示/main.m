%% Load data file
A = load('move.data');

%% Data preprocessing
A(:, 1) = A(:, 1) - A(1, 1);

samplingRate = 50;
samplingTime = 1000 / samplingRate;

[~, I] = unique(A(:, 1), 'first');
A = A(I, :);

temA = [];
temA(:, 1) = (A(1, 1) : samplingTime : A(end, 1))';
for i = 2 : size(A, 2)
    temA(:, i) = spline(A(:, 1), A(:, i), temA(:, 1));
end
T = temA(:, 1);
A = temA(:, 2 : 3);

%% From acceleration to velocity and displacement

dt = samplingTime / 1000;
dV = A * dt;
V = cumsum(dV);
dD = V * dt + A * dt ^ 2 / 2;
D = cumsum(dD);

%% draw acceleration, velocity and displacement of X and Y axis

subplot(3, 2, 1);
plot(T, A(:, 1));
title('X轴加速度');

subplot(3, 2, 2);
plot(T, A(:, 2));
title('Y轴加速度');

subplot(3, 2, 3);
plot(T, V(:, 1));
title('X轴速度');

subplot(3, 2, 4);
plot(T, V(:, 2));
title('Y轴速度');

subplot(3, 2, 5);
plot(T, D(:, 1));
title('X轴位移');

subplot(3, 2, 6);
plot(T, D(:, 2));
title('Y轴位移');

%% Animation: draw trace

w = max(max(abs(D))) + 0.05;
figure(2);
axis([-w, w, -w, w]);

for i = 1 : size(D, 1)
    hold on;
    plot(D(i, 1), D(i, 2), 'ro');
    pause(dt);
end
