% This funcion converts OSA/ANSI index to n and m needed for 
% calculation of Zernike polynomials, for more: 
% https://en.wikipedia.org/wiki/Zernike_polynomials

function [n,m] = osa2nm_gen(j_idx)
    i = 0;
    curr_n = 0;
    n = [];
    m = [];
    while 1
        for idx = -curr_n:2:curr_n
            n = [n curr_n];
            m = [m idx];
            i = i + 1;
            if i > j_idx
                return
            end
        end
        curr_n = curr_n + 1;
    end
end

