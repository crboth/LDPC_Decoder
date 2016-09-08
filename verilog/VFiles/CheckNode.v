`include "Comparator.v"
module CheckNode(Rwires, Qwires, rst, clk);
    //num_connections must be at least 2
	parameter num_connections = 6;
	parameter prec = 4;

	output 	signed 	[num_connections*prec-1:0] 	Rwires;
	input 	signed 	[num_connections*prec-1:0] 	Qwires;
	input                                       	rst;
	input                                       	clk;

	wire                            sign_product;
	wire    [num_connections-1:0]   Qsigns;
	wire    [num_connections-1:0]   Rsigns;		
	wire 	signed	[prec-1:0]      abs_Q		[num_connections-1:0];
	wire 	signed	[prec-1:0]      abs_R		[num_connections-1:0];	
    	wire 	signed	[prec-1:0]      Rvalues		[num_connections-1:0];
	reg 	signed	[prec-1:0]      Rreg		[num_connections-1:0];
	wire 	signed	[prec-1:0]      min_tree_wires 	[num_connections*2-2:0];
    	wire 	signed	[prec-1:0]      sec_min_tree_wires [num_connections*2-2:0];
    	wire	signed	[prec-1:0]      min;
	wire	signed	[prec-1:0]      second_min;
	genvar 		i;
    	reg [9:0]   	j;

	assign sign_product = ^Qsigns;
	
	assign min = min_tree_wires[num_connections*2-2];
	assign second_min = sec_min_tree_wires[num_connections*2-2];

    	generate
		
		for(i = 0; i < num_connections; i = i+1) begin :genblk0
		        assign min_tree_wires[i] = abs_Q[i];
			assign sec_min_tree_wires[i] = {prec{1'b1}};
		end

		for(i=0; i<num_connections; i=i+1) begin :genblk1
		        assign Rwires[prec*(i+1)-1:prec*i] = Rreg[i];
		end

		for(i=0; i < num_connections-1; i = i+1) begin :genblk2
		        Comparator #(prec) Comp(min_tree_wires[i+num_connections],  sec_min_tree_wires[i+num_connections],
		                        min_tree_wires[i*2],     min_tree_wires[i*2+1],
		                        sec_min_tree_wires[i*2], sec_min_tree_wires[i*2+1]);
		end

		for(i=0; i < num_connections; i=i+1) begin :genblk3
		        assign Qsigns[i] = 	Qwires[(i+1)*prec - 1];
		        assign abs_Q[i]  = 	Qsigns[i] 	 ? -Qwires[(i+1)*prec-1:i*prec]:Qwires[(i+1)*prec-1:i*prec];
		        assign Rsigns[i] = 	sign_product 	 ? !Qsigns[i] 	: Qsigns[i];
		        assign abs_R[i]	 = 	(abs_Q[i] == min)? second_min 	: min;
		        assign Rvalues[i]=	Rsigns[i]	 ? -abs_R[i]    : abs_R[i];
		end
    	endgenerate

	always @(negedge clk, posedge rst) begin
		if(rst) begin
			for(j = 0; j < num_connections; j = j+1) begin
				Rreg[j] <= 0;
			end
		end
		else begin
			for(j = 0; j < num_connections; j = j+1) begin
				Rreg[j] <= Rvalues[j];
			end
		end
	end			
endmodule
