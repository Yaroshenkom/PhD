% This function models human eye's optical system as
% a converging lens with aberration wavefront function defined by 
% Zernike coefficients C. Objects are placed at the distance "dist" (in um)
% in front of the cornea. Pupil radius also has to be in um.
% If you want unaberrated output - just make C = 0.

function [x_out,y_out] = zern_eye_model(x_in, y_in, dist, pupil_radius, C)
    % Eye's diameter in um
    R_eye = 23700;

    % Turn Cartesian coordinates into polar ones
    [phi_in, ro_in] = cart2pol(x_in, y_in);

    % Calculate unaberrated coordinates of input point (very simplified)
    ro_out = R_eye * ro_in / dist;
    phi_out = phi_in - pi;
    
    % Turn polar coordinates into Cartesian
    [x_out,y_out] = pol2cart(phi_out, ro_out);

    % Add aberrations
    [dx, dy] = zernshift(ro_in/pupil_radius, phi_in, C);
    x_out = x_out + dx * pupil_radius;
    y_out = y_out + dy * pupil_radius;
end

