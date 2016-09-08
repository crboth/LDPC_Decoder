`include "QuantizedAdder.v"
`include "QuantizedSubber.v"

module VarNode(P_v, x, Qwires, Rwires, llr, rst, clk);
	parameter num_connections = 5;
	parameter prec = 4;

	output  signed	[prec-1:0]                  	P_v;
	output                                      	x;
	output  signed 	[num_connections*prec-1:0] 	Qwires;
	input   signed  [num_connections*prec-1:0] 	Rwires;
	input   signed 	[prec-1:0]                  	llr;
	input                                       	rst;
	input                                       	clk;
	reg signed 	[num_connections*prec-1:0]	Qreg;
	wire signed 	[num_connections*prec-1:0]	sub_wires;    
    	wire signed	[prec-1:0]  			sum_tree_wires [num_connections*2-2:0];

    

    	genvar i;
	generate
	for(i=0; i<num_connections; i=i+1) begin : genblk1
		assign sum_tree_wires[i] = Rwires[(i+1)*prec-1: i*prec];
		QuantizedSubber #(prec) q_sub(sub_wires[(i+1)*prec - 1 : i*prec], P_v, Rwires[(i+1)*prec - 1 : i*prec]);
	end 

    //There is a difference in how the matlab script and the verilog quantize the sum of R values
    //Verilog saturates after each addition of two numbers, MATLAB after all numbers are added together
    //this is the source of the minor discrepency between their behavior

	for(i=0; i<num_connections-1; i=i+1) begin : genblk2
		QuantizedAdder #(prec) Rsumr(sum_tree_wires[i+num_connections], sum_tree_wires[i*2], sum_tree_wires[i*2+1]);                         
	end
	endgenerate

    	QuantizedAdder #(prec) Pv_calc(P_v, sum_tree_wires[num_connections*2-2], llr);
	assign x = P_v[prec-1];
	assign Qwires = Qreg;
	
	initial begin
		Qreg <= 0;
	end
	
	always @(posedge clk, posedge rst) begin
		if(!rst) begin
			Qreg <= sub_wires;
		end
		else begin
			Qreg <= 0;
		end
	end

endmodule


