module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
	output reg [7:0] out_byte,
    output done
); 

 

    parameter START=3'b000;
	parameter DATA =3'b001;
	parameter PCHK =3'b010;
	parameter STOP =3'b011;
	parameter WAIT =3'b100;
	parameter DONE =3'b101;
	
    reg [2:0] state ; 
	reg [2:0] next_state ;
	reg [2:0] cnt_data   ;
	wire      cnt_ok     ;
	reg       odd        ;
	reg       par_err    ;
	wire      ctl_clr    ;

	assign ctl_clr = (state==START) | (state==DONE) ;

	assign cnt_ok = (state==DATA) & (&cnt_data) ;
    always @(posedge clk ) begin
        // State flip-flops with asynchronous reset
        if(reset) 
            cnt_data <= 3'd0 ;
		else if(&cnt_data)
			cnt_data <= #1 3'd0 ;
        else if(state==DATA)
            cnt_data <= #1 cnt_data + 3'd1 ;
		else
			cnt_data <= #1 3'd0 ;
    end

    always @(posedge clk ) begin
        // State flip-flops with asynchronous reset
        if(reset) 
            out_byte <= 8'd0 ;
		else if(ctl_clr)
            out_byte <= #1 8'd0 ;
        else if(state==DATA)
            out_byte <= #1 {in,out_byte[7:1]} ;
    end

    always @(posedge clk ) begin
        // State flip-flops with asynchronous reset
        if(reset) 
            par_err <= 1'd0 ;
		else if(ctl_clr)
            par_err <= #1 1'd0 ;
        else if((state==PCHK) && (odd==in))
            par_err <= #1 1'b1 ;
    end


    always @(posedge clk ) begin
        // State flip-flops with asynchronous reset
        if(reset) 
            odd <= 1'd0 ;
		else if(ctl_clr)
            odd <= #1 1'd0 ;
        else if((state==DATA) && in)
            odd <= #1 ~odd ;
    end

    always @(*) begin
        // State transition logic
        case(state)
            START : next_state = ~in    ? DATA  : START ;
            DATA  : next_state = cnt_ok ? PCHK  : DATA  ;
			PCHK  : next_state = STOP                   ;
			STOP  : next_state = in     ? DONE  : WAIT  ;
			WAIT  : next_state = in     ? START : WAIT  ;
			DONE  : next_state = in     ? START : DATA  ;
			default : next_state = START ;
        endcase
    end

    always @(posedge clk ) begin
        // State flip-flops with asynchronous reset
        if(reset) 
            state <= 3'b000 ;
        else
            state <= #1 next_state ;
    end

    // Output logic
    assign done  = (state==DONE) & ~par_err ;
    

endmodule