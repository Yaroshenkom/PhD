% This function calculates image shift dx and dy due to Zernike
% coeffecients C of eye's optical system. ro should be 0<=ro<=1
% More info in section 4 of
% http://pbf.kpi.ua/en/docs/publications/Molebny_Retina_ray-tracing_technique.pdf 

function [dx,dy] = zernshift(ro, phi, C)
    % Get n and m for current C
    [n, m] = osa2nm_gen(size(C) - 1);
    n = n';
    m = m';
    % Calculate shifts:
    % 1. Calculate partial derivative dRnm(ro)/dro (formula 14 of the link)
    dRnm_dro = zeros(size(n));
    for i = 1:size(n,1)
        for k = 0:( n(i)-abs(m(i)) )/2
            dRnm_dro(i) = dRnm_dro(i) + ((-1)^factorial(n(i)-k)) * (n(i)-2*k) * (ro^(n(i)-2*k-1)) /...
                (factorial(k) * factorial( ( n(i)-abs(m(i)) )/2 - k ) * factorial(( n(i)+abs(m(i)) )/2-k));
        end
    end
    % 2. Calculate partial derivative dW(ro,phi)/dro (formula 13 of the link)
    dW_dro = 0.0;
    for i = 1:size(n,1)
        tmp = 0.0;
        if (m(i) < 0)
            % It's odd polynomial's derivative
            tmp = sin(abs(m(i)) * phi);
        else
            % It's even polynomial's derivative
            tmp = cos(m(i) * phi);
        end
        % Include norming coefficient Nnm
%         delta = 0;
%         if m(i) == 0
%             delta = 1;
%         end
%         Nnm = sqrt(2 * (n(i)+1) / (1 + delta));
        dW_dro = dW_dro + C(i) * dRnm_dro(i) * tmp;
    end
    % 3. Calculate Rnm(ro) (formula 7 of the link - it has typo, here is the correct variant)
    Rnm = zeros(size(n));
    for i = 1:size(n)
        for k = 0:( n(i)-abs(m(i)) )/2
            Rnm(i) = Rnm(i) + ((-1)^k) * factorial(n(i)-k) * (ro^(n(i)-2*k)) / ...
                (factorial(k) * factorial((n(i)+abs(m(i)))/2 - k) * factorial((n(i)-abs(m(i)))/2 - k));
        end
    end
    % 4. Calculate partial derivative dW(ro,phi)/dphi (formula 15 of the link)
    dW_dphi = 0.0;
    for i = 1:size(n)
        tmp = 0.0;
        if (m(i) < 0)
            % It's odd polynomial
            tmp = cos(abs(m(i)) * phi);
        else
            % It's even polynomial
            tmp = -sin(m(i) * phi);
        end
        % Include norming coefficient Nnm
%         delta = 0;
%         if m(i) == 0
%             delta = 1;
%         end
%         Nnm = sqrt(2 * (n(i)+1) / (1 + delta));
        dW_dphi = dW_dphi + abs(m(i)) * C(i) * Rnm(i) * tmp;
    end
    % 5. Calculate shifts by themselves (formulas 11-12)
    % Eye's diameter in meters to be compatible with traditional value of
    % the eye's refraction index
    R_eye = 0.023700;
    % Eye's refraction index
    n_refr = 1.336;
    % Shifts
    dy = (R_eye/n_refr) * (cos(phi) * dW_dro - sin(phi) * dW_dphi / ro);
    dx = (R_eye/n_refr) * (sin(phi) * dW_dro + cos(phi) * dW_dphi / ro);
end

