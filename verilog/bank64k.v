/**
 * Data Bank
 *
 * 128-bit-wide access, 64kbit (8KB) total.
 */

`timescale 1ns/1ps

/**** Module bank64k ****/
module bank64k(clk,
               rd_en,    rd_addr, rd_muxcode,
               wr_en,    wr_addr, wr_muxcode,
               rdi_word, wri_word,
               rdd_word, wrd_word,
               rdc_word, wrc_word);


/* Parameters */
parameter  w = 64;
parameter  a = 10;

/* Interface */
input  wire          clk;

input  wire          rd_en;
input  wire[a-1 : 0] rd_addr;
input  wire[  1 : 0] rd_muxcode;
input  wire          wr_en;
input  wire[a-1 : 0] wr_addr;
input  wire[  1 : 0] wr_muxcode;

output wire[w-1 : 0] rdi_word;
output wire[w-1 : 0] rdd_word;
output wire[w-1 : 0] rdc_word;

input  wire[w-1 : 0] wri_word;
input  wire[w-1 : 0] wrd_word;
input  wire[w-1 : 0] wrc_word;


/* Local */
wire[w-1 : 0] rd_word;
reg[w-1 : 0] wr_word;

// TODO move this MUX to the collision detection unit - why is it here?? The collision detection unit should be able to resolve collisions
/* Wiring */
always @(wri_word or wrd_word or wrc_word or wr_muxcode) begin
    case (wr_muxcode)
        2'b00: wr_word = wri_word;
        2'b01: wr_word = wrd_word;
        2'b10: wr_word = wrc_word;
        default: wr_word = {w{1'b0}};
    endcase
end

/* Bcast Read */
assign rdi_word = rd_word;
assign rdd_word = rd_word;
assign rdc_word = rd_word;

MVU_data_memory data_ram (
  .clka ( clk       ),       // input wire clka
  .clkb ( clk       ),       // input wire clkb

  .ena  ( wr_en     ),       // input wire ena
  .wea  ( 8'hFF     ),       // input wire [7 : 0] wea // for now only allow writing full 64 bits at one time, but in future we might want to accommodate writing half-words, particularly for the external interface
  .addra( wr_addr   ),       // input wire [9 : 0] addra
  .dina ( wr_word   ),       // input wire [63 : 0] dina
  .douta(           ),       // output wire [63 : 0] douta

  .enb  ( rd_en     ),       // input wire enb
  .web  ( 8'b0      ),       // input wire [7 : 0] web
  .addrb( rd_addr   ),       // input wire [9 : 0] addrb
  .dinb ( 64'b0     ),       // input wire [63 : 0] dinb
  .doutb( rd_word   )        // output wire [63 : 0] doutb
);

/* Module end */
endmodule
