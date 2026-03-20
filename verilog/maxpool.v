/**
 * Max-Pooling
 */

`timescale 1ns/1ps
/**** Module ****/
module maxpool #(
    parameter N = 32
) (
    input  wire                 clk,
    input  wire                 relu_en, // enables ReLU - otherwise passthrough din to maxpooler
    input  wire                 maxpool_load, // when high, loads din into output register. When low, output is max of din and its previous value. Tie high for no pooling
    input  wire                 din_valid, // data in is not always valid due to shacc behaviour so don't do any pooling with invalid values
    input  wire signed[N-1 : 0] din,
    output reg  signed[N-1 : 0] dout = 0
);

wire signed[N-1 : 0] after_relu;

assign after_relu = relu_en ? (din > 0 ? din : 0) : din; /* ReLU operation */

/* Max pooling */
always @(posedge clk) begin // TODO implement a reset signal
    if(maxpool_load) begin
        dout <= after_relu; // Tie load to 1 for no pooling
    end else if (din_valid) begin
        dout <= after_relu > dout ? after_relu : dout; // max(after_relu, dout)
    end else begin
        dout <= dout; // hold value if din is not valid
    end
end


/* Module end */
endmodule



/**** Test Module ****/
module test_maxpool();


/* Local parameters for test */
localparam N = 32;


/* Create input registers and output wires */
reg                  clk      = 0;
reg                  max_en   = 0;
reg                  max_clr  = 0;
reg                  max_pool = 0;
reg  signed[N-1 : 0] I        = 0;
wire signed[N-1 : 0] O;


/* Create instance */
maxpool #(N) master (clk, max_en, max_clr, max_pool, I, O);


/* Run test */
initial forever begin #10; $display("%t: %9d", $time, O); end
always  begin clk=0; #5; clk=1; #5;                       end
initial begin
	I= 0; max_en=1; max_clr=1; max_pool=0; #10;
	I= 1; max_en=1; max_clr=0; max_pool=0; #10;
	I= 0; max_en=1; max_clr=0; max_pool=0; #10;
	I=-4; max_en=1; max_clr=0; max_pool=0; #10;
	I=+5; max_en=1; max_clr=0; max_pool=0; #10;
	I= 0; max_en=1; max_clr=0; max_pool=1; #10;
	I=+1; max_en=1; max_clr=0; max_pool=1; #10;
	I=+9; max_en=1; max_clr=0; max_pool=1; #10;
	I=+1; max_en=1; max_clr=0; max_pool=1; #10;
	I=-1; max_en=1; max_clr=1; max_pool=1; #10;
	$finish();
end

endmodule
