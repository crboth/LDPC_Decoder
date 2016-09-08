module TreeComparator(min, sec_min, values);
	parameter num_values = 3;
	parameter prec = 5;

	output	[prec-1:0]              min;
	output	[prec-1:0]  			sec_min;
	input 	[num_values*prec-1:0] 	values;
			
	wire 	[prec-1:0]  min1;
	wire 	[prec-1:0]  min2;
	wire 	[prec-1:0]  sec_min1;
	wire	[prec-1:0]  sec_min2;

	wire 	[prec-1:0]  _min;
	wire 	[prec-1:0]  _sec_min;
    genvar log_con;
    genvar i;
    generate
        log_con = 0;
        for(i = num_values; i > 0; i = i-1) begin
            log_con += i;
        end
        
        wire 	[prec-1:0]  min_wires[0:log_con-1];
        wire 	[prec-1:0]  sec_min_wires[0:log_con-1];
		
	Comparator JoinTree(min, sec_min, min1, min2, sec_min1, sec_min2);
    
    generate
    for(i=0; i < num_values/2; i=i+1) begin
        always@(*) begin
            if(values[prec*(i+1)-1:prec*i] < values[prec*(i+2)-1:prec*(i+1)]) begin
                min_wires[i] <= values[prec*(i+1)-1:prec*i];
                sec_min_wires[i] <= values[prec*(i+2)-1:prec*(i+1)];
            end
            else begin
                sec_min_wires[i] <= values[prec*(i+1)-1:prec*i];
                min_wires[i] <= values[prec*(i+2)-1:prec*(i+1)];
            end
    end
        
        min_wires[i] = (values[prec*(i+1)-1:prec*i] < values[prec*(i+2)-1:prec*(i+1)] ? 
        

	generate 
	if(num_values == 1) begin
		assign min 		= values;
		assign second_min 	= {prec{1'b1}};
	end
	else if(num_values >= 2) begin
		assign min = _min;
		assign sec_min = _sec_min;
		TreeComparator2 #(num_values/2, prec) 			  LeftTree(min1, sec_min1,  left_vals);
		TreeComparator2 #(num_values-num_values/2, prec) RightTree(min2, sec_min2, right_vals);
	end
	endgenerate
endmodule
	


			
			
	

