	module Comparator(min, sec_min, min1, min2, sec_min1, sec_min2);
		parameter prec = 5;
		output	[prec - 1 : 0] min;
		output	[prec - 1 : 0] sec_min;
		
		input	[prec - 1 : 0] min1;
		input	[prec - 1 : 0] min2;
		input	[prec - 1 : 0] sec_min1;
		input	[prec - 1 : 0] sec_min2;

		wire	[prec - 1 : 0] not_min;
		wire	[prec - 1 : 0] not_max;
			
		assign {min, not_min}	= (min2 > min1) 	 ? {min1, min2}:{min2, min1};
		assign not_max 		= (sec_min1 <= sec_min2) ? sec_min1:sec_min2;
		assign sec_min		= (not_min <= not_max)	 ? not_min:not_max;
		
	endmodule
	
