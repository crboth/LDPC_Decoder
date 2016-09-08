function [out] = ldpc_decoder2(llr, SpHenc, max_iterations)
[row, col] = find(SpHenc);
[num_rows, ~] = size(SpHenc);
n = nnz(SpHenc);
k = 1:n;
rowi = 1:num_rows;
Q = zeros(1,n);
R = zeros(1,n);
i = 0;
P_v = llr;
sign_prod = zeros(1,num_rows);
mins = zeros(num_rows, 2);
%While a slightly more efficent algorithm might be possible by creating
%classes for the nodes to calculate and calculating their values directly, working on the H matrix format was very easy to do conceptually
while ( (i < max_iterations) && ~all(mod((P_v < 0)*double(transpose(SpHenc)),2) == zeros(1,num_rows)))
    spR = sparse(row,col,R);
    sum_of_Rs = sum(spR);
    P_v = llr + sum_of_Rs;
    Q(k) = P_v(col(k)) - R(k);
    sign_Q = logical(Q < 0);
    sign_prod(rowi) = mod(histc(row(sign_Q(k)),rowi),2);
    abs_Q = abs(Q);
    
    %This was my first stab at trying to find an efficent vectorized
    %approach to calculating R values
    
    %C Nodes send R values to each V node, each R value has the sign
    %of the sign product of the input Q values, and the absolute value of
    %the minimum Q value excluding its respective one. 
    
    %i.e. odd number of negative Qs means negative Rs, all the Rs have the
    %same abs value of the minimum Q except for the R corresponding to the
    %minimum Q, in which case it has the second min
    
    %Efficently finding both the min and the second min was challenging as
    %simply calling sort on say the 576x288 matrix is costly, instead the
    %list of Q values is sorted,(~1800 elements instead of 165k) and Unique is used to find the first
    %instance (and then again to find the second instance) of a Q value
    %corresponging to each row, aka the min for that row
    
    [~, ind] = sort(abs_Q);
    %These two unique calls take up ~50% of the runtime
    [~, ia ,~] = unique(row(ind));
    mins(rowi,1) = abs_Q(ind(ia(rowi)));
    ind(ia) = [];
    [~, ia ,~] = unique(row(ind));
    mins(rowi,2) = abs_Q(ind(ia(rowi)));
    R(k) = mins(row(k),1);
    R(abs_Q(k) == R(k)) = mins(row(abs_Q(k) == R(k)),2);
    R(sign_Q(k)) = -R(sign_Q(k));
    R(sign_prod(row(k)) == 1) = -R(sign_prod(row(k)) == 1);
    i = i+1;
end
out = P_v;
end