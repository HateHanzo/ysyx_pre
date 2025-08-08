module top_module(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
	input ground,
    output walk_left,
    output walk_right,
	output reg aaah ); //  

    parameter LEFT   = 2'b00 ;
	parameter RIGHT  = 2'b01 ;
	parameter FALL_L = 2'b10 ;
	parameter FALL_R = 2'b11 ;
	
    reg [1:0] state;
    reg [1:0] next_state;
	

    always @(*) begin
        // State transition logic
        case(state)
            LEFT :   next_state = ~ground  ? FALL_L :
			                    bump_left  ? RIGHT  : LEFT   ;
			RIGHT:   next_state = ~ground  ? FALL_R :
			                    bump_right ? LEFT   : RIGHT  ;
			FALL_L : next_state =  ground  ? LEFT   : FALL_L ;
			FALL_R : next_state =  ground  ? RIGHT  : FALL_R ;
        endcase
    end

    always @(posedge clk or posedge areset) begin
        if(areset) 
            state <= 2'b00 ;
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

endmodule