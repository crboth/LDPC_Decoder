function [q] = quantize(in)  
    global pbd pmax pmin
    temp = round(in*(2^(pbd)));
    temp(temp > pmax) = pmax;     
    temp(temp < pmin) = pmin;
    q = temp/(2^pbd);
end
    
       