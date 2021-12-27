% Generate input (coaxial circles)
circles = 4;
pts_in_circle = 6;
init_radius = 50;
[in_pts, total_pts_num] = gen_in_circles(pts_in_circle, circles, init_radius);

% Show pattern
figure;
scatter(in_pts(:, 1), in_pts(:, 2));

% Create training set:
% - network input - inclined points;
% - network output - zernike coefficients, normalized (from 0 to 1) with
% respect to pre-defined maximum and minimum values.
samples_num = 60000;
% Mins and maxes of Zernike coefficients (in um)
C_min_max = [
    0.001, 0.001;... n=0, m=0
    -0.20, 0.20;... n=1, m=-1
    -0.20, 0.20;... n=1, m=1
    -0.50, 0.50;... n=2, m=-2
    -7.50, 7.50;... n=2, m=0
    -1.00, 1.00;... n=2, m=2
    -0.20, 0.20;... n=3, m=-3
    -0.20, 0.20;... n=3, m=-1
    -0.20, 0.20;... n=3, m=1
    -0.20, 0.20;... n=3, m=3
    -0.20, 0.20;... n=4, m=-4
    -0.20, 0.20;... n=4, m=-2
    -0.20, 0.20;... n=4, m=0
    -0.20, 0.20;... n=4, m=2
    -0.20, 0.20;... n=4, m=4
    -0.20, 0.20;... n=5, m=-5
    -0.20, 0.20;... n=5, m=-3
    -0.20, 0.20;... n=5, m=-1
    -0.20, 0.20;... n=5, m=1
    -0.20, 0.20;... n=5, m=3
    -0.20, 0.20;... n=5, m=5
    -0.20, 0.20;... n=6, m=-6
    -0.20, 0.20;... n=6, m=-4
    -0.20, 0.20;... n=6, m=-2
    -0.20, 0.20;... n=6, m=0
    -0.20, 0.20;... n=6, m=2
    -0.20, 0.20;... n=6, m=4
    -0.20, 0.20;... n=6, m=6
];
% Generate random normalized (from 0 to 1) values
C_rnd_norm = rand(samples_num, size(C_min_max,1));
% Calculate weights which take into account C's amplitudes (norm by maximum
% amplitude)
C_weights = 1./ (C_min_max(:, 2) - C_min_max(:, 1));
% Turn random normalized C to just random
C_rnd = repmat(C_min_max(:, 1)', samples_num, 1) + (C_min_max(:, 2)' - C_min_max(:, 1)').*C_rnd_norm;
% Calculate network input - point coordinates on the retina
out_pts = zeros(total_pts_num, 2, samples_num);
for i = 1:samples_num
    for j = 1:total_pts_num
        [out_pts(j,1,i), out_pts(j,2,i)] = zern_eye_model(in_pts(j,1), in_pts(j,2), 35000, 2500, C_rnd(i,:)');
    end
end
% Show the first output pattern on the retina
figure;
scatter(out_pts(:, 1, 1), out_pts(:, 2, 1));

% Prepare network's inputs and outputs:
% - sort retina points by y in every sample (let's assume that we scan
% measurement from top to bottom)
net_in_tmp = zeros(total_pts_num, 2, samples_num);
for i = 1:samples_num
    [net_in_tmp(:,2,i), order] = sort(out_pts(:,2,i));
    tmp = out_pts(:,1,i);
    net_in_tmp(:,1,i) = tmp(order);
end
% - reshape it (one sample is the vector of (x1,x2,..,xN,y1,y2,..,yN))
net_in = zeros(samples_num, total_pts_num*2);
for i = 1:samples_num
    tmp = reshape(net_in_tmp(:,:,i), [], 1);
    net_in(i, :) = tmp';
end

% Also create and input for LSTM-based network
net_in_lstm = cell(samples_num, 1);
for i = 1:samples_num
    tmp = net_in_tmp(:,:,i);
    tmp = num2cell(tmp', [1 2]);
    net_in_lstm(i) = tmp;
end

% Final preparation for matlab's neural networks
net_in = net_in';
% net_out = ((C_rnd - repmat(C_min_max(:, 1)', samples_num, 1)) ./ C_weight)';
% net_out = (C_rnd - repmat(C_min_max(:, 1)', samples_num, 1))';
net_out = C_rnd_norm';
net_in_train = net_in(:,1:(samples_num*0.8));
net_in_valid = net_in(:,(samples_num*0.8 + 1):size(net_in,2));
net_out_train = net_out(:,1:(samples_num*0.8));
net_out_valid = net_out(:,(samples_num*0.8 + 1):size(net_out,2));

net_in_lstm_train = net_in_lstm(1:(samples_num*0.8));
net_in_lstm_valid = net_in_lstm((samples_num*0.8 + 1):size(net_in,2));