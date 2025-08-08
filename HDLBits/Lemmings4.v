module top_module(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
	input ground,
	input dig,
    output walk_left,
    output walk_right,
	output aaah,
    output	digging); //  

    parameter LEFT   = 3'b000 ;
	parameter RIGHT  = 3'b001 ;
	parameter FALL_L = 3'b010 ;
	parameter FALL_R = 3'b011 ;
	parameter DIG_L  = 3'b100 ;
	parameter DIG_R  = 3'b101 ;
	parameter SPLAT  = 3'b110 ;
	
	reg       aaah_pre  ;
    reg [2:0] state;
    reg [2:0] next_state;
	reg [4:0] cnt_fall  ;
	wire      splat_ok  ;

    always @(*) begin
        // State transition logic
        case(state)
        LEFT :   next_state = ~ground     ? FALL_L :
			                   dig        ? DIG_L  :
			                   bump_left  ? RIGHT  : LEFT   ;
		RIGHT:   next_state = ~ground     ? FALL_R :
							   dig        ? DIG_R  :
	                           bump_right ? LEFT   : RIGHT  ;
		FALL_L : next_state =  (ground & splat_ok) ? SPLAT : 
	                            ground             ? LEFT  : FALL_L ;
		FALL_R : next_state =  (ground & splat_ok) ? SPLAT : 
		                        ground             ? RIGHT : FALL_R ;
		DIG_L  : next_state =  ~ground    ? FALL_L : DIG_L  ;
		DIG_R  : next_state =  ~ground    ? FALL_R : DIG_R  ;
		SPLAT  : next_state =  SPLAT ;
		default :next_state =  LEFT ;
        endcase
    end

    always @(posedge clk or posedge areset) begin
        if(areset) 
            state <= 3'b000 ;
        else
            state <= #1 next_state ;
    end

    assign splat_ok = cnt_fall==5'd20 ;
    always @(posedge clk or posedge areset) begin
        if(areset) 
            cnt_fall <= 5'd0 ;
	    else if(splat_ok)
            cnt_fall <= #1 cnt_fall;
        else if((state==FALL_L) || (state==FALL_R))
            cnt_fall <= #1 cnt_fall + 5'd1;
		else
		    cnt_fall <= #1 5'd0;
    end

    assign aaah = aaah_pre & ~(state==SPLAT ) ;
    always @(posedge clk or posedge areset) begin
        if(areset) 
            aaah_pre <= 1'b0 ;
        else
            aaah_pre <= #1  ~ground;
    end

    // Output logic
    assign walk_left  = (state==LEFT ) ;
    assign walk_right = (state==RIGHT) ;
	assign digging    = (state==DIG_R) | (state==DIG_L) ;

endmodule
