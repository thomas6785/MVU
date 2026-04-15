package mvu_pkg;


// Parameters
localparam NMVU    =  8;   // Number of MVUs. Ideally a Power-of-2.
localparam N       = 64;   // N x N matrix-vector product size. Power-of-2.
localparam BBIAS   = 32;   // Bitwidth of bias values

localparam BMVUA   = $clog2(NMVU);  // Bitwidth of MVU          Address

localparam BACC     = 27;               // Bitwidth of Accumulators
localparam BSCALERP = 27;               // Bitwidth of the scaler output

// Quantizer parameters
localparam BQMSBIDX     = $clog2(BSCALERP); // Bitwidth of the quantizer MSB location specifier
localparam BQBOUT       = $clog2(BSCALERP); // Bitwidth of the quantizer
localparam QBWOUTBD     = $clog2(BSCALERP); // Bitwidth of the quantizer bit-depth out specifier

// Other Parameters
localparam BCNTDWN       = 29; // Bitwidth of the countdown ports
localparam BPREC         = 6;  // Bitwidth of the precision ports
localparam BBWADDR       = 9;  // Bitwidth of the weight base address ports
localparam BBDADDR       = 15; // Bitwidth of the data base address ports
localparam BJUMP         = 15; // Bitwidth of the stride ports
localparam BLENGTH       = 15; // Bitwidth of the length ports
localparam BSCALERB      = 16; // Bitwidth of the scaler parameter
localparam VVPSTAGES     = 3;  // Number of stages in the VVP pipeline
localparam SCALERLATENCY = 3;  // Number of stages in the scaler pipeline
localparam MAXPOOLSTAGES = 1;  // Number of max pool pipeline stages
localparam MEMRDLATENCY  = 2;  // Memory read latency
localparam NJUMPS        = 5;  // Number of address jump parameters available
localparam MVU_INTERCONN_DLY = 1;

localparam PIPELINE_DLY  = VVPSTAGES + SCALERLATENCY + MAXPOOLSTAGES + MEMRDLATENCY;

// Data bank parameters
localparam NDBANK  = 32;   // Number of N-bit, 1024-element Data BANK.
localparam BDBANKABS = $clog2(NDBANK);  // Bitwidth of Data    BANK Address Bank Select for internal reading
localparam BDBANKAWS = 10;              // Bitwidth of Data    BANK Address Line Select for internal reading

localparam BDBANKA = BDBANKABS+BDBANKAWS;                // Bitwidth of Data    BANK Address for internal reading
localparam BDBANKW = N;                 // Bitwidth of Data    BANK Word for internal reading
localparam BDBANKA_EXT = BDBANKA + $clog2(BDBANKW/32); // Bitwidth of Data BANK Address for external interface (assuming 32bit word for external interface)

// Weight bank parameters
localparam BWBANKA = 9;             	// Bitwidth of Weights BANK Address for internal reading
localparam BWBANKW = 4096;          	// Bitwidth of Weights BANK Word
localparam BWBANKA_EXT = BWBANKA + $clog2(BWBANKW/32); // Bitwidth of Weights BANK Address for external interface (assuming 32bit word for external interface)

// Scalar memory bank parameters
localparam BSBANKA     = 6;             // Bitwidth of Scaler BANK address for internal reading
localparam BSBANKW     = BSCALERB*N;    // Bitwidth of Scaler BANK word
localparam BSBANKA_EXT = BSBANKA + $clog2(BSBANKW/32);             // Bitwidth of Scaler BANK address for external interface (assuming 32bit word for external interface)

// Bias memory bank parameters
localparam BBBANKA     = 6;             // Bitwidth of Bias BANK address
localparam BBBANKW     = BBIAS*N;       // Bitwidth of Bias BANK word
localparam BBBANKA_EXT = BBBANKA + $clog2(BBBANKW/32);             // Bitwidth of Bias BANK address for external interface (assuming 32bit word for external interface)

typedef enum logic [11:0] {
	CSR_MVUWBASEPTR         = 12'h000,  //Base address for weight memory
	CSR_MVUIBASEPTR         = 12'h004,  //Base address for input memory
	CSR_MVUSBASEPTR         = 12'h008,  //Base address for scaler memory (6 bits)
	CSR_MVUBBASEPTR         = 12'h00c,  //Base address for bias memory (6 bits)
	CSR_MVUOBASEPTR         = 12'h010,  //Output base address
	CSR_MVUWJUMP_0          = 12'h014,  //Weight address jumps in loops 0
	CSR_MVUWJUMP_1          = 12'h018,  //Weight address jumps in loops 1
	CSR_MVUWJUMP_2          = 12'h01c,  //Weight address jumps in loops 2
	CSR_MVUWJUMP_3          = 12'h020,  //Weight address jumps in loops 3
	CSR_MVUWJUMP_4          = 12'h024,  //Weight address jumps in loops 4
	CSR_MVUIJUMP_0          = 12'h028,  //Input data address jumps in loops 0
	CSR_MVUIJUMP_1          = 12'h02c,  //Input data address jumps in loops 1
	CSR_MVUIJUMP_2          = 12'h030,  //Input data address jumps in loops 2
	CSR_MVUIJUMP_3          = 12'h034,  //Input data address jumps in loops 3
	CSR_MVUIJUMP_4          = 12'h038,  //Input data address jumps in loops 4
	CSR_MVUSJUMP_0          = 12'h03c,  //Scaler memory address jumps (6 bits)
	CSR_MVUSJUMP_1          = 12'h040,  //Scaler memory address jumps (6 bits)
	CSR_MVUSJUMP_2          = 12'h044,  //Scaler memory address jumps (6 bits)
	CSR_MVUSJUMP_3          = 12'h048,  //Scaler memory address jumps (6 bits)
	CSR_MVUSJUMP_4          = 12'h04c,  //Scaler memory address jumps (6 bits)
	CSR_MVUBJUMP_0          = 12'h050,  //Bias memory address jumps (6 bits)
	CSR_MVUBJUMP_1          = 12'h054,  //Bias memory address jumps (6 bits)
	CSR_MVUBJUMP_2          = 12'h058,  //Bias memory address jumps (6 bits)
	CSR_MVUBJUMP_3          = 12'h05c,  //Bias memory address jumps (6 bits)
	CSR_MVUBJUMP_4          = 12'h060,  //Bias memory address jumps (6 bits)
	CSR_MVUOJUMP_0          = 12'h064,  //Output data address jumps in loops 0
	CSR_MVUOJUMP_1          = 12'h068,  //Output data address jumps in loops 1
	CSR_MVUOJUMP_2          = 12'h06c,  //Output data address jumps in loops 2
	CSR_MVUOJUMP_3          = 12'h070,  //Output data address jumps in loops 3
	CSR_MVUOJUMP_4          = 12'h074,  //Output data address jumps in loops 4
	CSR_MVUWLENGTH_1        = 12'h078,  //Weight length in loops 1
	CSR_MVUWLENGTH_2        = 12'h07c,  //Weight length in loops 2
	CSR_MVUWLENGTH_3        = 12'h080,  //Weight length in loops 3
	CSR_MVUWLENGTH_4        = 12'h084,  //Weight length in loops 3
	CSR_MVUILENGTH_1        = 12'h088,  //Input data length in loops 0
	CSR_MVUILENGTH_2        = 12'h08c,  //Input data length in loops 1
	CSR_MVUILENGTH_3        = 12'h090,  //Input data length in loops 2
	CSR_MVUILENGTH_4        = 12'h094,  //Input data length in loops 3
	CSR_MVUSLENGTH_1        = 12'h098,  //Scaler tensor length 15 bits
	CSR_MVUSLENGTH_2        = 12'h09c,  //Scaler tensor length 15 bits
	CSR_MVUSLENGTH_3        = 12'h0a0,  //Scaler tensor length 15 bits
	CSR_MVUSLENGTH_4        = 12'h0a4,  //Scaler tensor length 15 bits
	CSR_MVUBLENGTH_1        = 12'h0a8,  //Bias tensor length 15 bits
	CSR_MVUBLENGTH_2        = 12'h0ac,  //Bias tensor length 15 bits
	CSR_MVUBLENGTH_3        = 12'h0b0,  //Bias tensor length 15 bits
	CSR_MVUBLENGTH_4        = 12'h0b4,  //Bias tensor length 15 bits
	CSR_MVUOLENGTH_1        = 12'h0b8,  //Output data length in loops 0
	CSR_MVUOLENGTH_2        = 12'h0bc,  //Output data length in loops 1
	CSR_MVUOLENGTH_3        = 12'h0c0,  //Output data length in loops 2
	CSR_MVUOLENGTH_4        = 12'h0c4,  //Output data length in loops 3
	CSR_MVUPRECISION        = 12'h0c8,  //Precision in bits for all tensors
	CSR_MVUSTATUS           = 12'h0cc,  //Status of MVU
	CSR_MVUCOMMAND          = 12'h0d0,  //Kick to send command.
	CSR_MVUQUANT            = 12'h0d4,  //MSB index position
	CSR_MVUSCALER           = 12'h0d8,  //fixed point operand for multiplicative scaling
	CSR_MVUCONFIG1          = 12'h0dc,  //Shift/accumulator load on jump select (only 0-4 valid) Pool/Activation clear on jump select (only 0-4 valid)
	CSR_MVUOMVUSEL          = 12'h0e0,  //MVU selector bits for output
	CSR_MVUUSESCALER_MEM    = 12'h0e4,  //Use scalar mem if 1; otherwise use the scaler_b input for scaling
	CSR_MVUUSEBIAS_MEM      = 12'h0e8   //Use the bias memory if 1; if not, not bias is added in the scaler
} mvu_csr_t;

typedef logic [BWBANKW-1 : 0 ] w_data_t;
typedef w_data_t w_data_q_t[$];

typedef logic [BDBANKW-1 : 0 ] a_data_t;
typedef a_data_t a_data_q_t[$];

// Define a structure to hold all MVU configuration signals
typedef struct {
	logic                          start; 		       	               // Start the MVU job
	logic        [          1 : 0] mul_mode;            			   // Config: multiply mode
    logic                          d_signed;                           // Config: input data signed
    logic                          w_signed;                           // Config: weights signed
    logic                          max_en;                             // Config: max pool enable // TODO review if these are actually used? I think they aren't
    logic                          max_clr;                            // Config: max pool clear // TODO review if these are actually used? I think they aren't
    logic                          quant_clr;                          // Quantizer: clear // TODO review if these are actually used? I think they aren't
    logic                          max_pool;                           // Config: max pool mode // TODO review if these are actually used? I think they aren't
    logic        [ BQMSBIDX-1 : 0] quant_msbidx;                       // Quantizer: bit position index of the MSB
    logic        [  BCNTDWN-1 : 0] countdown;                          // Config: number of clocks to countdown for given task
    logic        [    BPREC-1 : 0] wprecision;                         // Config: weight precision
    logic        [    BPREC-1 : 0] iprecision;                         // Config: input precision
    logic        [    BPREC-1 : 0] oprecision;                         // Config: output precision
    logic        [  BBWADDR-1 : 0] wbaseaddr;                          // Config: weight memory base address
    logic        [  BBDADDR-1 : 0] ibaseaddr;                          // Config: data memory base address for input
    logic        [  BSBANKA-1 : 0] sbaseaddr;                          // Config: scaler memory base address
    logic        [  BBBANKA-1 : 0] bbaseaddr;                          // Config: bias memory base address
    logic        [  BBDADDR-1 : 0] obaseaddr;                          // Config: data memory base address for output
    logic        [     NMVU-1 : 0] omvusel;                            // Config: MVU selector bits for output
    logic signed [    BJUMP-1 : 0] wjump[NJUMPS-1 : 0];                // Config: weight jumps
    logic signed [    BJUMP-1 : 0] ijump[NJUMPS-1 : 0];                // Config: input jumps
    logic signed [    BJUMP-1 : 0] sjump[NJUMPS-1 : 0];                // Config: scaler jumps
    logic signed [    BJUMP-1 : 0] bjump[NJUMPS-1 : 0];                // Config: bias jumps
    logic        [    BJUMP-1 : 0] ojump[NJUMPS-1 : 0];                // Config: output jumps
    logic        [  BLENGTH-1 : 0] wlength[NJUMPS-1 : 1];              // Config: weight lengths
    logic        [  BLENGTH-1 : 0] ilength[NJUMPS-1 : 1];              // Config: input length
    logic        [  BLENGTH-1 : 0] slength[NJUMPS-1 : 1];              // Config: scaler length
    logic        [  BLENGTH-1 : 0] blength[NJUMPS-1 : 1];              // Config: bias length
    logic        [  BLENGTH-1 : 0] olength[NJUMPS-1 : 1];              // Config: output length
    logic        [ BSCALERB-1 : 0] scaler_b;                           // Config: multiplicative scaler (operand 'b')
    logic                          usescaler_mem;                      // Config: use scalar mem if 1; otherwise use the scaler_b input for scaling
    logic                          usebias_mem;                        // Config: use the bias memory if 1; if not, not bias is added in the scaler
    logic        [   NJUMPS-1 : 0] shacc_load_sel;                     // Config: select jump trigger for shift/accumultor load
    logic        [   NJUMPS-1 : 0] zigzag_step_sel;                    // Config: select jump trigger for stepping the zig-zag address generator
	logic        [   NJUMPS-1 : 0] pool_load_sel;                      // Config: select jump trigger for loading new value into the max pooler. For no pooling, set all 1's
} mvu_cfg_signals_t;

endpackage
