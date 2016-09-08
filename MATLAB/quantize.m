function [q] = quantize(in, pad, pbd)
%precision was set as precision above and below decimal the, total number of bits is equal to their sum plus a sign bit

%Admittedly this is a wonky format, total number of bits and how to
%shift the decimal would clearly be superior
    pmax = 2^(pad+pbd) -1;
    pmin = -(2^(pad+pbd));
    temp = round(in*(2^(pbd)));
    temp(temp > pmax(1,1)) = pmax(1,1);     
    temp(temp < pmin) = pmin;
    q = temp/(2^pbd);
end
    
       