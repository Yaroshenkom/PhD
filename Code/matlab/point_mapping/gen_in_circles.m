function [out_pts, num_of_pts_total] = gen_in_circles(init_points_num, num_of_circ, rad_init)
    % Calculate the amount of points
    num_of_pts_total = 0;
    for i = 1:num_of_circ
        num_of_pts_total = num_of_pts_total + init_points_num * i;
    end
    out_pts = zeros(num_of_pts_total, 2);

    % The output pattern consists coaxial circles
    curr_pt = 0;
    for i = 1:num_of_circ
        % Radius and amount of points in current circle
        rad = rad_init * i;
        num_of_pts = init_points_num * i;
        for j = 0:num_of_pts-1
            curr_pt = curr_pt + 1;
            pt_coord = [rad * cos(j/num_of_pts * 2 * pi); rad * sin(j/num_of_pts * 2 * pi)];
            out_pts(curr_pt, :) = pt_coord;
        end
    end
end

