module QuantizedAdder(sum, in1, in2);
	parameter 	prec = 5;

	output 	signed 		[prec - 1 : 0] 	sum;
	input 	signed		[prec - 1 : 0] 	in1;
	input 	signed		[prec - 1 : 0]	in2;
	wire 	signed		[prec	  : 0]	sum_wire;

	assign sum_wire = in1 + in2;
	assign sum 		= (sum_wire[prec] == sum_wire[prec-1]) ? sum_wire[prec - 1 : 0] : {sum_wire[prec],{(prec - 1){sum_wire[prec - 1]}}};
	
endmodule
