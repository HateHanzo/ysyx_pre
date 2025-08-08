module top_module(
    input clk,
    input [7:0] in,
    input reset,    // Synchronous reset
    output done); // 

    parameter BYTE1 = 2'b00 ;
	parameter BYTE2 = 2'b01 ;
	parameter BYTE3 = 2'b10 ;
	parameter DONE  = 2'b11 ;
	
    reg [1:0] state;
    reg [1:0] next_state;
	

    always @(*) begin
        // State transition logic
        case(state)
			BYTE1 : next_state = in[3] ? BYTE2 : BYTE1 ;
			BYTE2 : next_state = BYTE3 ;
			BYTE3 : next_state = DONE ;
			DONE  : next_state = in[3] ? BYTE2 : BYTE1 ;
        endcase
    end

    always @(posedge clk ) begin
        if(reset) 
            state <= 2'b00 ;
        else
            state <= #1 next_state ;
    end



    // Output logic
	assign done = state==DONE ;


endmodule