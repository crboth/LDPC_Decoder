function [out] = ldpc_decoder_v(llr, SpHenc) 
    [row, col] = find(SpHenc);
    [num_rows, num_cols] = size(SpHenc);
    n = nnz(SpHenc);
    k = 1:n;
    rowi = 1:num_rows;
    Q = zeros(1,n);
    R = zeros(1,n);
    i = 0;
    P_v = llr;
    sign_prod = zeros(1,num_rows);
    mins = zeros(num_rows, 2);
    while ( (i < 25) && ~all(mod((P_v < 0)*double(transpose(SpHenc)),2) == zeros(1,num_rows)))
        spR = sparse(row,col,R);
        sum_of_Rs = quantize(sum(spR));  
        P_v = llr + sum_of_Rs;
        P_v = quantize(P_v);        
        Q(k) = P_v(col(k)) - R(k);
        Q = quantize(Q);   
        sign_Q = logical(Q < 0);
        sign_prod(rowi) = mod(histc(row(sign_Q(k)),rowi),2);
        abs_Q = quantize(abs(Q));       
        [~, ind] = sort(abs_Q);
        [~, ia ,~] = unique(row(ind));
        mins(rowi,1) = abs_Q(ind(ia(rowi))); 
        ind(ia) = [];
        [~, ia ,~] = unique(row(ind));
        mins(rowi,2) = abs_Q(ind(ia(rowi))); 
        R(k) = mins(row(k),1);
        R(abs_Q(k) == R(k)) = mins(row(abs_Q(k) == R(k)),2);
        R(sign_Q(k)) = -R(sign_Q(k));
        R(sign_prod(row(k)) == 1) = -R(sign_prod(row(k)) == 1);
        R = quantize(R);        
        i = i+1;
   end
   out = P_v;
end