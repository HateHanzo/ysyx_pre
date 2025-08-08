module top_module(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
	input ground,
	input dig,
    output walk_left,
    output walk_right,
	output reg aaah,
    output	digging); //  

    parameter LEFT   = 3'b000 ;
	parameter RIGHT  = 3'b001 ;
	parameter FALL_L = 3'b010 ;
	parameter FALL_R = 3'b011 ;
	parameter DIG_L  = 3'b100 ;
	parameter DIG_R  = 3'b101 ;
	
    reg [2:0] state;
    reg [2:0] next_state;
	

    always @(*) begin
        // State transition logic
        case(state)
            LEFT :   next_state = ~ground     ? FALL_L :
			                       dig        ? DIG_L  :
			                       bump_left  ? RIGHT  : LEFT   ;
			RIGHT:   next_state = ~ground     ? FALL_R :
			                       dig        ? DIG_R  :
			                       bump_right ? LEFT   : RIGHT  ;
			FALL_L : next_state =  ground     ? LEFT   : FALL_L ;
			FALL_R : next_state =  ground     ? RIGHT  : FALL_R ;
			DIG_L  : next_state =  ~ground    ? FALL_L : DIG_L  ;
			DIG_R  : next_state =  ~ground    ? FALL_R : DIG_R  ;
			default :next_state =  LEFT ;
        endcase
    end

    always @(posedge clk or posedge areset) begin
        if(areset) 
            state <= 3'b000 ;
        else
            state <= #1 next_state ;
    end

    always @(posedge clk or posedge areset) begin
        if(areset) 
            aaah <= 1'b0 ;
        else
            aaah <= #1  ~ground;
    end

    // Output logic
    assign walk_left  = (state==LEFT ) ;
    assign walk_right = (state==RIGHT) ;
	assign digging    = (state==DIG_R) | (state==DIG_L) ;

endmodule