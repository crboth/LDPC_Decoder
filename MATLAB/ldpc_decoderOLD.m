function [out] = ldpc_decoderOLD(llr, H, max_iterations) 
    %This is an iteration of the first decoder simulation I wrote, It's
    %already been somewhat optimized over the completley C style original

    
    %It's orders of magnitude slower than the final iteration
    [row, col] = find(H);
    n = nnz(H);
    Q = zeros(288,576);
    R = zeros(288,576);
    i = 0;
    P_v = llr;
    while ( (i < max_iterations) && ~all(mod((P_v < 0)*transpose(H),2) == zeros(1,288)))
       %Calculate Q values
       sum_of_Rs = zeros(1,576);
       for k = 1:n
          sum_of_Rs(1,col(k)) = sum_of_Rs(1,col(k)) + R(row(k),col(k));
       end

       P_v = llr + sum_of_Rs;

       for k = 1:n
           Q(row(k,1),col(k,1)) = P_v(1,col(k,1)) - R(row(k,1),col(k,1));
       end    
       %Calculate R values
       for k = 1:n
            rowk = row(k,1);
            colk = col(k,1);
            q_min = Inf;%flintmax;
            sign_prod = 1;
           for j = 1:576
              if ((H(rowk,j)) && ~(j == colk))
                temp_sign = sign(Q(rowk,j));
                if(~temp_sign)
                    temp_sign = 1;
                end
                    sign_prod = sign_prod*temp_sign;
                if abs(Q(rowk,j)) < q_min %bugged
                    q_min = abs(Q(rowk,j));
                end
              end
           end
           R(rowk,colk) = sign_prod * q_min;
       end
       i = i+1;
    end
    out = P_v;
end
%temp_sign = mod(sum(sign(Q(H(rowk,:) != 0)