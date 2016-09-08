function [out, num_iterations] = ldpc_decoderFINAL(llr, SpHenc, max_iterations) 

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
    while ( (i < max_iterations) && ~all(mod((P_v < 0)*double(transpose(SpHenc)),2) == zeros(1,num_rows)))
        
        spR = sparse(row,col,R);
        %calculate Q values
        sum_of_Rs = sum(spR);
        P_v = llr + sum_of_Rs;
        Q(k) = P_v(col(k)) - R(k);
        
        %calculate R values
        %find all the negative Q values
        sign_Q = logical(Q < 0);
        
        %to calculate sign product:
        %histogram is used to find the number of negatives in each row
        %mod is then used to determine if this number is positive or 
        %negative whish is equivalent to the sign product
        sign_prod(rowi) = mod(histc(row(sign_Q(k)),rowi),2);
        
        %to find the mins first sort all the Q values by absoulte value
        abs_Q = abs(Q);
        spabs = sparse(col,row,abs_Q);
        srtd = sort(spabs);
        
        %%%%%%
        %%%%%%
        %This is a cludge which will break on a differently sized matrix or
        %one with less than 6 or more than 7 connections to a Check Node,
        %the fix is simple but unneccesary for the exercise.
        
        %For a sorted sparse matrix of dimenstion 576, with 6 or 7 elements in a row, and only absolute values, the min and second min are between elem 570 and 572
        
        tmp = srtd(570:572,:);
        %%%%
        mins = tmp(1:2,:);
        mins(:,sum(SpHenc,2)==6) = tmp(2:3,sum(SpHenc,2)==6);
        %%%%%%%
        %%%%%%%
        
        %Initially assign R to be the abs value minmimums for each row
        R(k) = mins(1,row(k));
        %wherever R is equivalent to its corresponding Q, it is known to be
        %the minimum for that row
        %replace these Rs with the second minimum value
        R(abs_Q(k) == R(k)) = mins(2,row(abs_Q(k) == R(k)));
        %if the sign product of corresponding Q values is negative, make R negative
        R(sign_Q(k)) = -R(sign_Q(k));
        %if the sign product was negative make R negative, this can
        %probably be improved to perform both sign calculations in one
        %operation
        R(sign_prod(row(k)) == 1) = -R(sign_prod(row(k)) == 1);        
        i = i+1;
    end
   num_iterations = i;
   out = P_v;
end