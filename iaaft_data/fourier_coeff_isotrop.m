function output_coeff = fourier_coeff_isotrop(x)

[y_size x_size] = size(x);
if ( (y_size == 1) | (x_size == 1) ) % input is a 1D power spectrum that has to be made 2D
    output_coeff = fourier_coeff_isotroph_sub(x);
else                                 % input is a 2D power spectrum that has to be made 3D by a cylinder rotation
    output_coeff = zeros(x_size, x_size, y_size); % the y_size of the old 2D matrix is the z_size of the 3D matrix
    for j = 1:y_size
        xx = x(j, :);
        temp = fourier_coeff_isotroph_sub(xx);
        output_coeff(:, :, j) = temp;
    end
end


function a=fourier_coeff_isotroph_sub(x)
% This function makes a 2D power spectrum out of a 1D one
% Assumption is isotrophy.

ori_vector_size = length(x);
ori_half_size   = ori_vector_size/2;
a = zeros(ori_vector_size); % The 2D Fourier matrix

for t1 = 1:ori_half_size+1
    for t2 = 1:ori_half_size+1
        index = 1 + round(  sqrt( (t1-1)^2 + (t2-1)^2 )  );
        if ( index > ori_half_size + 1 )
            index = ori_half_size + 1;
        end
        t3 = 2 + ori_vector_size - t1;
        if ( t3 > ori_vector_size ) 
            t3 = t1;
        end
        t4 = 2 + ori_vector_size - t2;
        if ( t4 > ori_vector_size ) 
            t4 = t2;
        end
        if ( index > 1 )
            coeff = x(index) / sqrt(index-1); % index-1 is the radius of the circel
        else
            coeff = x(index); % x(1); the DC-component of the Fourier spectrum should be zero anyway.
        end        
        a(t1,t2) = coeff;
        a(t3,t2) = coeff;
        a(t1,t4) = coeff;
        a(t3,t4) = coeff;
    end
end
