% Get one validation sample and compare it to the truth
C_norm_pred = predict(net, net_in_lstm_valid(74));
C_pred = C_min_max(:, 1) + (C_min_max(:, 2) - C_min_max(:, 1)) .* C_norm_pred';
% C_pred = C_min_max(:, 1) + C_norm_pred';
C_pred = C_pred
C_true = C_min_max(:, 1) + (C_min_max(:, 2) - C_min_max(:, 1)) .* net_out_valid(:,74);
% C_true = C_min_max(:, 1) + net_out_valid(:,2);
C_true = C_true

pred_pts = zeros(total_pts_num, 2);
true_pts = zeros(total_pts_num, 2);
for i = 1:total_pts_num
    [pred_pts(i,1), pred_pts(i,2)] = zern_eye_model(in_pts(i,1), in_pts(i,2), 35000, 2500, C_pred);
    [true_pts(i,1), true_pts(i,2)] = zern_eye_model(in_pts(i,1), in_pts(i,2), 35000, 2500, C_true);
end

% Show the first output pattern on the retina
figure('Name','Point prediction example');
scatter(pred_pts(:, 1), pred_pts(:, 2), 'red', 'DisplayName', 'Predicted');
hold on;
scatter(true_pts(:, 1), true_pts(:, 2), 'blue', 'DisplayName', 'True');
hold off;

% Try to calculate the mapping of output-to-input points
erroneous_pts = zeros(size(net_out_valid, 2)/100, 1);
total_err = 0.0;
for i = 1:size(net_out_valid, 2)/100
    % Get Zernike coefficients
    C_norm_pred = predict(net, net_in_lstm_valid(i));
    C_pred = C_min_max(:, 1) + (C_min_max(:, 2) - C_min_max(:, 1)) .* C_norm_pred';
    C_true = C_min_max(:, 1) + (C_min_max(:, 2) - C_min_max(:, 1)) .* net_out_valid(:,i);
    
    % Calculate coordinates of true and predicted points
    pred_pts = zeros(total_pts_num, 2);
    true_pts = zeros(total_pts_num, 2);
    for j = 1:total_pts_num
        [pred_pts(j,1), pred_pts(j,2)] = zern_eye_model(in_pts(j,1), in_pts(j,2), 35000, 2500, C_pred);
        [true_pts(j,1), true_pts(j,2)] = zern_eye_model(in_pts(j,1), in_pts(j,2), 35000, 2500, C_true);
    end
    
    % Mapping by itself by kmeans-clustering
    idxs = knnsearch(true_pts, pred_pts);

    % Check the result
    err_cnt = 0.0;
    for j = 1:total_pts_num
        if (idxs(j) ~= j)
            err_cnt = err_cnt + 1;
        end
    end

    total_err = total_err + err_cnt;
    erroneous_pts(i) = err_cnt;
end

avg_err = (total_err / (size(net_out_valid, 2)/100)) / total_pts_num
