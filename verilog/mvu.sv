/**
 * Matrix-Vector Unit
 */

`timescale 1 ns / 1 ps
/**** Module mvu ****/
module mvu import mvu_pkg::*; #(
    /* Parameters */
    parameter  N       = 64,   /* N x N matrix-vector product size. Power-of-2. */
    parameter  NDBANK  = 32,   /* Number of N-bit, 1024-element Data BANK. */
    parameter  BBIAS   = 32,   // Bit witdh of the bias values

    localparam CLOG2N      = $clog2(N),     /* clog2(N) */

    localparam BWBANKA     = 9,             /* Bitwidth of Weights BANK Address */
    localparam BWBANKW     = N*N,           /* Bitwidth of Weights BANK Word */
    localparam BDBANKABS   = $clog2(NDBANK),/* Bitwidth of Data    BANK Address Bank Select */
    localparam BDBANKAWS   = 10,            /* Bitwidth of Data    BANK Address Word Select */
    localparam BDBANKA     = BDBANKABS+     /* Bitwidth of Data    BANK Address */
                            BDBANKAWS,
    localparam BDBANKW     = N,             /* Bitwidth of Data    BANK Word */
    localparam BSUM        = CLOG2N+2,      /* Bitwidth of Sums */
    parameter BACC         = 27,            /* Bitwidth of Accumulators */

    parameter BSCALERA     = BACC,
    parameter BSCALERB     = 16,
    parameter BSCALERC     = 27,
    parameter BSCALERD     = 27,
    parameter BSCALERP     = 27,

    localparam BSBANKA     = 6,             // Bitwidth of Scaler BANK address
    localparam BSBANKW     = BSCALERB*N,    // Bitwidth of Scaler BANK word
    localparam BBBANKA     = 6,             // Bitwidth of Scaler BANK address
    localparam BBBANKW     = BBIAS*N,       // Bitwidth of Scaler BANK word


    // Quantizer parameters
    parameter  QMSBLOCBD  = $clog2(BSCALERP)   // Bitwidth of the quantizer MSB location specifier
) (
    /* Interface */
    input  wire                 clk,
    input  wire                 run,
    input  wire[        1 : 0]  mul_mode,
    input  wire                 neg_acc,                 // Negate the inputs to the accumulators
    input  wire                 shacc_clr,
    input  wire                 shacc_load,
    input  wire                 shacc_acc,
    input  wire                 shacc_sh,
    input  wire                 scaler_clr,             // Scaler: clear/reset
    input  wire[BSCALERB-1 : 0] scaler_b,               // Scaler: multiplier operand
    input  wire                 usescaler_mem,
    input  wire                 usebias_mem,
    input  wire                 max_en, // TODO signal is not used
    input  wire                 max_clr,
    input  wire                 max_pool,

    // Quantizer input signals
    input  wire                  quant_clr,
    input  wire[QMSBLOCBD-1 : 0] quant_msbidx,
    input  wire                  quant_load,
    input  wire                  quant_step,

    // Weight memory signals
    input  wire[  BWBANKA-1 : 0]	rdw_addr,
    input  wire[BWBANKA-1 : 0]	wrw_addr,			// Weight memory: write address
    input  wire[BWBANKW-1: 0]	wrw_word,			// Weight memory: write word
    input  wire						wrw_en,				// Weight memory: write enable
    input  wire[BWBANKW/8-1:0] wrw_be,

    // Scaler memory signals
    input   wire                rds_en,                 // Scaler memory: read enable
    input   wire[BSBANKA-1 : 0] rds_addr,               // Scaler memory: read address
    input   wire[BSBANKA-1 : 0] wrs_addr,               // Scaler memory: write address
    input   wire[BSBANKW-1 : 0] wrs_word,               // Scaler memory: write word
    input   wire                wrs_en,                 // Scaler memory: write enable
    input   wire[BSBANKW/8-1:0] wrs_be,

    // Bias memory signals
    input   wire                rdb_en,                 // Bias memory: read enable
    input   wire[BBBANKA-1 : 0] rdb_addr,               // Bias memory: read address
    input   wire[BBBANKA-1 : 0] wrb_addr,               // Bias memory: write address
    input   wire[BBBANKW-1 : 0] wrb_word,               // Bias memory: write word
    input   wire[BBBANKW/8-1:0] wrb_be,
    input   wire                wrb_en,                 // Bias memory: write enable

    input  wire                rdd_en,
    output wire                rdd_grnt,
    input  wire[BDBANKA-1 : 0] rdd_addr,
    input  wire                wrd_en,
    output wire                wrd_grnt,
    input  wire[BDBANKA-1 : 0] wrd_addr,

    input  wire                rdi_en,
    output wire                rdi_grnt,
    input  wire[BDBANKA-1 : 0] rdi_addr,
    output reg [BDBANKW-1 : 0] rdi_word,
    input  wire                wri_en,
    output wire                wri_grnt,
    input  wire[BDBANKA-1 : 0] wri_addr,
    input  wire[BDBANKW-1 : 0] wri_word,

    input  wire                rdc_en,
    output wire                rdc_grnt,
    input  wire[BDBANKA-1 : 0] rdc_addr,
    output reg [BDBANKW-1 : 0] rdc_word,
    input  wire                wrc_en,
    output wire                wrc_grnt,
    input  wire[BDBANKA-1 : 0] wrc_addr,
    input  wire[BDBANKW-1 : 0] wrc_word,

    output wire[BDBANKW-1 : 0] mvu_word_out
);

/* Generation Variables */
genvar i, j;


/* Local Wires */
wire                rd_en;
wire                wr_en;
wire[1 : 0]         wr_muxcode;
wire[BDBANKA-1 : 0] wr_addr;
wire                rdw_en;
wire[BWBANKW-1 : 0] rdw_word;

reg [BWBANKW-1 : 0]     core_weights;
wire[BDBANKW-1 : 0]     core_data;
wire[BSUM*N-1  : 0]     core_out;
wire signed[BSUM-1 : 0] core_out_signed [N-1 : 0];
wire signed[BSUM-1 : 0] shacc_in        [N-1 : 0];
wire[BACC-1  : 0]       shacc_out       [N-1 : 0];
wire[BSCALERP-1 : 0]    scaler_out      [N-1 : 0];
wire[BSCALERP-1 : 0]    pool_out        [N-1 : 0];
wire[BDBANKW-1 : 0]     quant_out;
reg [BDBANKW-1 : 0]     rdd_word;
wire[BDBANKW-1 : 0]     wrd_word;

wire[BDBANKW-1 : 0] rdd_words [NDBANK-1:0];
wire[BDBANKW-1 : 0] rdi_words [NDBANK-1:0];
wire[BDBANKW-1 : 0] rdc_words [NDBANK-1:0];

wire[BSBANKW-1 : 0]        rds_word;                // Scaler memory: read word
wire[BBBANKW-1 : 0]        rdb_word;                // Bias memory: read word
wire[BSCALERB-1 : 0]       scaler_mult_op[N-1 : 0]; // Scaler input multiplier operand
wire[BSCALERC-1 : 0]       scaler_post_op[N-1 : 0]; // Scaler input postadd operand



/* Wiring */
cdru    #(BDBANKABS, BDBANKAWS)    read_cdu     (rdi_en, rdi_addr, rdi_grnt,
                                      rdd_en, rdd_addr, rdd_grnt,
                                      rdc_en, rdc_addr, rdc_grnt,
                                      rd_en);

cdwu    #(BDBANKABS, BDBANKAWS)    write_cdu    (wri_en, wri_addr, wri_grnt,
                                      wrd_en, wrd_addr, wrd_grnt,
                                      wrc_en, wrc_addr, wrc_grnt,
                                      wr_en,  wr_addr,  wr_muxcode);


/* Matrix-vector product unit */
mvp     #(N, 'b0010101) matrix_core  (clk, mul_mode, core_weights, core_data, core_out);


/* Weight memory banks */
assign rdw_en = run; // always read a weight while we are running
always @(posedge clk) core_weights <= rdw_word; // load the read weights into the matrix core

// Xilinx IP for BRAM
MVU_weight_memory weights_bank (
  .clka ( clk           ),   // input clka
  .clkb ( clk           ),   // input clkb

  .ena  ( wrw_en        ),   // input ena                   write enable
  .wea  ( wrw_be        ),   // input [511 : 0] wea         byte-wise write enable
  .addra( wrw_addr      ),   // input [8 : 0] addra         write address
  .dina ( wrw_word      ),   // input [4095 : 0] dina       write data

  .enb  ( rdw_en        ),   // input enb                   read enable
  .addrb( rdw_addr      ),   // input [8 : 0] addrb         read address
  .doutb( rdw_word      )    // output [4095 : 0] doutb     read data
);

// Xilinx IP for BRAM
MVU_scaler_memory scalers_bank (
  .clka ( clk           ),   // input clka
  .clkb ( clk           ),   // input clkb

  .ena  ( wrs_en        ),   // input ena                   write enable
  .wea  ( wrs_be        ),   // input [127 : 0] wea         byte-wise write enable
  .addra( wrs_addr      ),   // input [5 : 0] addra         write address
  .dina ( wrs_word      ),   // input [1023 : 0] dina       write data

  .enb  ( rds_en        ),   // input enb                   read enable
  .addrb( rds_addr      ),   // input [5 : 0] addrb         read address
  .doutb( rds_word      )    // output [1023 : 0] doutb     read data
);

// Xilinx IP for BRAM
MVU_bias_memory bias_bank (
  .clka ( clk           ),   // input clka
  .clkb ( clk           ),   // input clkb

  .ena  ( wrb_en        ),   // input ena                   write enable
  .wea  ( wrb_be        ),   // input [255 : 0] wea         byte-wise write enable
  .addra( wrb_addr      ),   // input [5 : 0] addra         write address
  .dina ( wrb_word      ),   // input [2047 : 0] dina       write data

  .enb  ( rdb_en        ),   // input enb                   read enable
  .addrb( rdb_addr      ),   // input [5 : 0] addrb         read address
  .doutb( rdb_word      )    // output [2047 : 0] doutb     read data
);

// Negate the core output before accumulation, if the negation control is set to 1
generate for (i=0; i < N; i=i+1) begin: acc_in_array
    assign core_out_signed[i] = core_out[i*BSUM +: BSUM];
    assign shacc_in[i] = neg_acc ? -core_out_signed[i] : core_out_signed[i];
end endgenerate

/* Shift/Accumulators */
generate for(i=0;i<N;i=i+1) begin:shaccarray
    shacc   #(BACC, BSUM) accumulator(clk, shacc_clr, shacc_load, shacc_acc, shacc_sh,
                                      shacc_in[i],
                                      shacc_out[i]);
end endgenerate

/* Scalers */
generate for (i=0; i < N; i=i+1) begin: scalerarray

    assign scaler_mult_op[i] = usescaler_mem ? rds_word[i*BSCALERB +: BSCALERB] : scaler_b;
    assign scaler_post_op[i] = usebias_mem ? rdb_word[i*BBIAS +: BSCALERC] : 0;

    fixedpointscaler #(
        .BA(BSCALERA),
        .BB(BSCALERB),
        .BC(BSCALERC),
        .BD(BSCALERD),
        .BP(BSCALERP)
    ) scaler (
        .clk(clk),
        .clr(scaler_clr),
        .a(shacc_out[i]),
        .b(scaler_mult_op[i]),
        .c(scaler_post_op[i]),
        .d({BSCALERD{1'b0}}),
        .p(scaler_out[i])
    );
end endgenerate


/* Max poolers */
wire relu_en;
wire maxpool_load;
assign relu_en       = max_en;
assign maxpool_load = ~max_clr; // TODO remove this hack
generate for(i=0;i<N;i=i+1) begin:poolarray
    maxpool #(BSCALERP) pooler (
        .clk(clk),
        .relu_en(relu_en),
        .maxpool_load(maxpool_load),
        .din_valid(), // TODO logic for this signal. Should generally be 0, but go to 1 at the end of each accumulation phase
        .din(scaler_out[i]),
        .dout(pool_out[i])
);
end endgenerate


/* Quantizers */
generate for(i=0;i<N;i=i+1) begin:quantarray
    quantser #(
        .BWIN       (BSCALERP)
    ) quantser_unit (
        .clk        (clk),
        .clr        (quant_clr),
        .msbidx     (quant_msbidx),
        .load       (quant_load),
        .step       (quant_step),
        .din        (pool_out[i]),
        .dout       (quant_out[i])
    );
end endgenerate


// TODO refactor these banks, what the hell were they doing? The collision detection can handle MUXing the addr and wdata signals, and there's no need to have three identical rdata signals
/* Data Banks */
generate for(i=0;i<NDBANK;i=i+1) begin:bankarray
    wire                rdi_bankhit = rdi_grnt & (rdi_addr[BDBANKAWS +: BDBANKABS] == i);
    wire                rdd_bankhit = rdd_grnt & (rdd_addr[BDBANKAWS +: BDBANKABS] == i);
    wire                rdc_bankhit = rdc_grnt & (rdc_addr[BDBANKAWS +: BDBANKABS] == i);
    wire                rd_bankhit  = rdi_bankhit | rdd_bankhit | rdc_bankhit;
    wire                wr_bankhit  = wr_addr [BDBANKAWS +: BDBANKABS] == i;
    wire[BDBANKA-1 : 0] rd_addr     = (rdi_grnt & rdi_bankhit) ? rdi_addr :
									  ((rdd_grnt & rdd_bankhit) ? rdd_addr : rdc_addr);
    wire[1 : 0]         rd_muxcode  = (rdi_grnt & rdi_bankhit) ?     2'd0 :
									  ((rdd_grnt & rdd_bankhit) ?     2'd1 : 2'd2);
    bank64k #(BDBANKW, BDBANKAWS) db (clk, // TODO this is weirdly implemented? If collision handling is done in cdwu, why do we pass in all three ports into the bank?
        rd_en & rd_bankhit, rd_addr[0 +: BDBANKAWS], rd_muxcode,
        wr_en & wr_bankhit, wr_addr[0 +: BDBANKAWS], wr_muxcode,
        rdi_words[i], wri_word,
        rdd_words[i], wrd_word,
        rdc_words[i], wrc_word
    );
end endgenerate

assign rdd_word = rdd_words[rdd_addr[BDBANKAWS +: BDBANKABS]];
assign rdc_word = rdc_words[rdc_addr[BDBANKAWS +: BDBANKABS]];
assign rdi_word = rdi_words[rdi_addr[BDBANKAWS +: BDBANKABS]];

assign core_data = rdd_word;
assign wrd_word  = quant_out;
assign mvu_word_out = quant_out;



/* Module end */
endmodule
