module top_module(
    input         clk,
    input  [7:0]  in,
    input         reset,    // Synchronous reset
	output [23:0] out_bytes,
    output        done);    // 

    parameter BYTE1 = 2'b00 ;
	parameter BYTE2 = 2'b01 ;
	parameter BYTE3 = 2'b10 ;
	parameter DONE  = 2'b11 ;
	
    reg [1:0] state;
    reg [1:0] next_state;
	reg [7:0] in_d1,in_d2,in_d3 ;

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

    always @(posedge clk ) begin
        if(reset) begin
            in_d1 <= 8'h00 ;
			in_d2 <= 8'h00 ;
			in_d3 <= 8'h00 ;
		end
        else begin
            in_d1 <= #1 in ;
			in_d2 <= #1 in_d1 ;
			in_d3 <= #1 in_d2 ;
		end
    end

    // Output logic
	assign done = state==DONE ;
	assign out_bytes = {in_d3,in_d2,in_d1} ;

endmodule