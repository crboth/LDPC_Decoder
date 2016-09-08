%generates the top level verilog module of the LDPC decoder
function verigen(H, prec)
fID = fopen('VFiles/LDPC.v','w');
num_rows = 288;
num_cols = 576;
%could have passed these values in from the script

% num_con_each_Vnode
conV = sum(H,1); %sums all columns into row vector, total number of connections for a Var Node
%num_con_each_Cnode
conC = sum(H,2); %sums all rows into a column vector

fprintf(fID,'`include "VarNode.v"\n');
fprintf(fID,'`include "CheckNode.v"\n');
%These defines could be removed in favor of just directly using the
%value
fprintf(fID,'`define prec %d\n', prec);
for i = 1:576
    fprintf(fID,'`define n_con_v%d %d\n', i, conV(i));
end
for j = 1:288
    fprintf(fID,'`define n_con_c%d %d\n', j, conC(j));
end
fprintf(fID,'\n\nmodule LDPC(out, x, done, llr, clk, rst);\n');

fprintf(fID,'output [%d:0] out;\n',num_cols*prec - 1);
fprintf(fID,'output [%d:0] x;\n',num_cols-1);
fprintf(fID,'output done;\n');

fprintf(fID,'input [%d:0] llr;\n',576*prec - 1);
fprintf(fID,'input clk;\n');
fprintf(fID,'input rst;\n');
fprintf(fID,'reg [4:0] count;\n');
fprintf(fID,'reg  done;\n');
fprintf(fID,'wire [%d:0] x;\n',num_cols - 1);
fprintf(fID,'wire [%d:0] out_check;\n',num_rows - 1);

nth_in_c = zeros(num_cols,num_rows); %nth_in_c[a col][n]   = The row where the nth 1 in a col is
nth_in_r = zeros(num_rows,num_cols); %nth_in_r[a row][n]   = The col where the nth 1 in a row is

for i = 1:576
    for j = 1:288
        if(H(j,i))
            k = 1;
            while(nth_in_c(i,k) ~= 0)
                k = k + 1;
            end
            nth_in_c(i,k) = j;
            k = 1;
            while(nth_in_r(j,k) ~= 0)
                k = k + 1;
            end
            nth_in_r(j,k) = i;
            
            fprintf(fID,'\twire signed [`prec-1:0] Rwire_%d_%d;',  i,j);
            fprintf(fID,'\twire signed [`prec-1:0] Qwire_%d_%d;\n ',i,j);
        end
    end
end



%possibly redo this for tristate QR wire
fprintf(fID, '\n\n');
for i = 1:576
    fprintf(fID,'\twire signed [`prec*`n_con_v%d-1:0] Rwires_v%d;', i,i);
    fprintf(fID,'\twire signed [`prec*`n_con_v%d-1:0] Qwires_v%d;\n', i,i);
    for k = 1:conV(i)
        fprintf(fID,'\t\tassign Rwires_v%d[%d:%d] = Rwire_%d_%d;', i, k*prec-1,prec*(k-1), i, nth_in_c(i,k)); %
        fprintf(fID,'\tassign Qwire_%d_%d = Qwires_v%d[%d:%d];\n', i, nth_in_c(i,k), i, k*prec-1,prec*(k-1)); %j = nth_in_c[i][k]
    end
end
for j = 1:288
    fprintf(fID,'\twire signed [`prec*`n_con_c%d-1:0] Rwires_c%d;', j, j);
    fprintf(fID,'\twire signed [`prec*`n_con_c%d-1:0] Qwires_c%d;\n', j, j);
    for k = 1:conC(j)
        fprintf(fID,'\t\tassign Qwires_c%d[%d:%d] = Qwire_%d_%d;', j, k*prec-1,prec*(k-1), nth_in_r(j,k), j); %%%i = nth_in_r[j][k]
        fprintf(fID,'\tassign Rwire_%d_%d   = Rwires_c%d[%d:%d];\n', nth_in_r(j,k), j, j, k*prec-1,prec*(k-1)); %
    end
end

for j= 1:288
    fprintf(fID,'\tCheckNode #(`n_con_c%d, `prec) node_c%d(Rwires_c%d, Qwires_c%d, rst, clk);\n', j, j, j, j);
end


for i = 1:576
    fprintf(fID,'\tVarNode #(`n_con_v%d, `prec) node_v%d(out[%d:%d], x[%d], Qwires_v%d, Rwires_v%d, llr[%d:%d], rst, clk);\n', i, i, prec*(i)-1, (i-1)*prec, i-1, i, i, i*prec-1,(i-1)*prec);
end

for j = 1:288
    fprintf(fID,'assign out_check[%d] =',j-1);
    first = true;
    for i = 1:576
        if(H(j,i))
            if(first)
                first = false;
                fprintf(fID,' x[%d]',i-1);
            else
                fprintf(fID,' + x[%d]',i-1);
            end
            
        end
    end
    fprintf(fID,';\n');
end
fprintf(fID, 'always@(posedge clk) begin\n\tif(rst) begin\n\t\tcount <= 0;\n\t\tdone <= 0;\n\tend\n\t else if((count == 25) || (out_check == 0)) begin\n\t\t done <= 1;\n\tend\n\telse if (count < 25) begin\n\t\tcount <= count + 1;\n\tend\nend\n');
fprintf(fID,'endmodule\n');
end
