//
// MVU top level
//
// Notes:
// * For wlength_X and ilength_X parameters, the value to assign is actual_length - 1.
//
//
`timescale 1ns/1ps

/**** Module ****/
module mvutop import mvu_pkg::*; ( 
                                    MVU_EXT_INTERFACE mvu_ext,
                                    input mvu_pkg::mvu_cfg_signals_t mvu_cfg
                                 );


genvar i;

/* Local Wires */

// MVU Weight memory control
logic[NMVU*BWBANKA-1 : 0] rdw_addr;

// MVU Data memory control
logic[        NMVU-1 : 0] rdd_en;
logic[        NMVU-1 : 0] rdd_grnt;
logic[NMVU*BDBANKA-1 : 0] rdd_addr;
logic[        NMVU-1 : 0] wrd_en;
logic[        NMVU-1 : 0] wrd_grnt; // TODO this signal is not used - there is no handling for a write conflict
logic[NMVU*BDBANKA-1 : 0] wrd_addr;

// MVU Scaler and Bias memory control
logic[        NMVU-1 : 0] rds_en;                        // Scaler memory: read enable
logic[NMVU*BSBANKA-1 : 0] rds_addr;                      // Scaler memory: read address
logic[     BSBANKA-1 : 0] rds_addr_offset [NMVU-1 : 0];  // Scaler memory: read address offset from scaler mem AGU
logic[        NMVU-1 : 0] rdb_en;                        // Bias memory: read enable
logic[NMVU*BBBANKA-1 : 0] rdb_addr;                      // Bias memory: read address
logic[     BBBANKA-1 : 0] rdb_addr_offset [NMVU-1 : 0];  // Bias memory: read address offset from bias mem AGU

// Interconnect
logic                     ic_clr_int;
logic[   NMVU*NMVU-1 : 0] ic_send_to;
logic[        NMVU-1 : 0] ic_send_en;
logic[NMVU*BDBANKA-1 : 0] ic_send_addr;
logic[NMVU*BDBANKW-1 : 0] ic_send_word;
logic[        NMVU-1 : 0] ic_recv_en;
logic[   NMVU*NMVU-1 : 0] ic_recv_from;
logic[NMVU*BDBANKA-1 : 0] ic_recv_addr;
logic[NMVU*BDBANKW-1 : 0] ic_recv_word;
logic[NMVU*BDBANKW-1 : 0] rdi_word;
logic[        NMVU-1 : 0] wri_en;
logic[NMVU*BDBANKW-1 : 0] wri_word;

logic[        NMVU-1 : 0] rdi_en;
logic[        NMVU-1 : 0] rdi_grnt;
logic[NMVU*BDBANKA-1 : 0] rdi_addr;
logic[        NMVU-1 : 0] wri_grnt;
logic[NMVU*BDBANKA-1 : 0] wri_addr;

logic[NMVU*BDBANKW-1 : 0] mvu_word_out;

// Scaler
logic[        NMVU-1 : 0] scaler_clr;            // Scaler: clear/reset

// Quantizer
logic[        NMVU-1 : 0] quant_start;           // Quantizer: signal to start quantizing
logic[        NMVU-1 : 0] quant_stall;           // Quantizer: stall
logic[      NMVU*N-1 : 0] quantarray_out;        // Quantizer: output
logic[  BPREC*NMVU-1 : 0] quant_bwout;           // Quantizer: output bitwidth
logic[        NMVU-1 : 0] quant_load;            // Quantizer: load base address
logic[        NMVU-1 : 0] quant_step;            // Quantizer: step the quantizer
logic[        NMVU-1 : 0] quant_ctrl_clr;        // Quantizer: clear/reset controller
logic[        NMVU-1 : 0] quant_clr_int;         // Quantizer: internal clear control

// Output data write back to memory
// TODO: DO SOMETHING USEFUL WITH THESE SIGNALS
logic[        NMVU-1 : 0] outstep;
logic[        NMVU-1 : 0] outload;

// Other wires
logic[        NMVU-1 : 0] inagu_clr;
logic[        NMVU-1 : 0] controller_clr;    // Controller clear/reset
logic[        NMVU-1 : 0] step;              // Step if 1, stall if 0
logic[        NMVU-1 : 0] run;               // Running if 1
logic[        NMVU-1 : 0] d_msb;             // Input data address on MSB
logic[        NMVU-1 : 0] w_msb;             // Weight data address on MSB
logic[        NMVU-1 : 0] neg_acc;           // Negate the input to the accumulators
logic[        NMVU-1 : 0] neg_acc_dly;       // Negation control delayed
logic[        NMVU-1 : 0] shacc_load;        // Accumulator load control
logic[        NMVU-1 : 0] shacc_sh;          // Accumulator shift control
logic[        NMVU-1 : 0] shacc_acc;         // Accumulator accumulate control
logic[        NMVU-1 : 0] shacc_clr_int;     // Accumulator clear internal control
logic[        NMVU-1 : 0] shacc_load_start;  // Accumulator load from start of job
logic[        NMVU-1 : 0] agu_sh_out;        // Input AGU shift accumulator
logic[        NMVU-1 : 0] agu_shacc_done;    // AGU accumulator done indicator
logic[        NMVU-1 : 0] run_acc;           // Run signal for the accumulator/shifters
logic[        NMVU-1 : 0] shacc_done;        // Accumulator done control
logic[        NMVU-1 : 0] maxpool_done;      // Max pool done control
logic[        NMVU-1 : 0] outagu_clr;        // Clear the output AGU
logic[        NMVU-1 : 0] outagu_load;       // Load the output AGU base address
logic[      NJUMPS-1 : 0] wagu_on_j[NMVU-1 : 0];      // Indicates when a weight address jump X
logic[        NMVU-1 : 0] scaleragu_step;    // Steps the scaler memory AGU
logic[        NMVU-1 : 0] biasagu_step;      // Steps the bias memory AGU
logic[        NMVU-1 : 0] scaleragu_clr;     // Clears the state of the Scaler memory AGU
logic[        NMVU-1 : 0] biasagu_clr;       // Clears the state of the bias memory AGU
logic[        NMVU-1 : 0] scaleragu_clr_dly; // Clears the state of the Scaler memory AGU
logic[        NMVU-1 : 0] biasagu_clr_dly;   // Clears the state of the bias memory AGU


/*
* Wiring 
*/

/*
* Interconnect
*/

interconn #(
    .N(NMVU),
    .W(BDBANKW),
    .BADDR(BDBANKA)
) ic (
    .clk(mvu_ext.clk),
    .clr(ic_clr_int),
    .send_to(ic_send_to),
    .send_en(ic_send_en),
    .send_addr(ic_send_addr),
    .send_word(ic_send_word),
    .recv_from(ic_recv_from),
    .recv_en(ic_recv_en),
    .recv_addr(ic_recv_addr),
    .recv_word(ic_recv_word)
);

// Interconnect wires
generate for(i=0; i < NMVU; i = i+1) begin
    assign ic_send_to[i*NMVU +: NMVU] = mvu_cfg.omvusel[i];
    assign ic_send_en[i] = (| mvu_cfg.omvusel[i]) & !mvu_cfg.omvusel[i][i] & outstep[i];
end endgenerate

assign ic_send_word = mvu_word_out;
assign ic_send_addr = wrd_addr;
assign wri_word     = ic_recv_word;
assign wri_en       = ic_recv_en;
assign wri_addr     = ic_recv_addr;

// TODO: FIGURE OUT WHERE TO WIRE OTHER INTERCONNECT DATA ACCESS SIGNAL
assign rdi_en           = 0;
//assign rdi_grnt         = 0;
assign rdi_addr         = 0;
//assign wri_grnt         = 0;

assign rdd_en           = run;                              // MVU reads when running

generate for(i=0; i < NMVU; i = i+1) begin
    assign rds_en[i] = run[i] & mvu_cfg.usescaler_mem[i];            // No need to read from scaler mem if not using
    assign rdb_en[i] = run[i] & mvu_cfg.usebias_mem[i];              // No need to read from bias mem if not using
end endgenerate

// TODO: WIRE THESE UP TO SOMETHING USEFUL
assign outload          = 0;
assign quant_stall      = 0;
assign step             = {NMVU{1'b1}};                      // No stalls for now

// Accumulator signals
assign run_acc          = run;                              // No stalls for now
assign shacc_load       = shacc_done | shacc_load_start;    // Load accumulator with current output of MVP's

// Clear signals (just connect to global reset for now)
assign ic_clr_int       = !mvu_ext.rst_n | mvu_ext.ic_clr;
assign controller_clr   = {NMVU{!mvu_ext.rst_n}};
assign inagu_clr        = {NMVU{!mvu_ext.rst_n}} | mvu_cfg.start;
assign outagu_clr       = {NMVU{!mvu_ext.rst_n}};
assign shacc_clr_int    = {NMVU{!mvu_ext.rst_n}} | mvu_ext.shacc_clr;       // Clear the accumulator
assign scaleragu_clr    = {NMVU{!mvu_ext.rst_n}} | scaleragu_clr_dly;
assign biasagu_clr      = {NMVU{!mvu_ext.rst_n}} | biasagu_clr_dly;
assign scaler_clr       = {NMVU{!mvu_ext.rst_n}};
assign quant_clr_int    = {NMVU{!mvu_ext.rst_n}} | mvu_cfg.quant_clr;

// Quantizer and output control signals
assign quant_start      = maxpool_done;
assign outstep          = quant_step;
assign quant_ctrl_clr   = {NMVU{!mvu_ext.rst_n}} | mvu_cfg.quant_clr;

// MVU Data Memory control
generate for(i = 0; i < NMVU; i = i + 1) begin: wrd_en_array
    assign wrd_en[i] = outstep[i] & mvu_cfg.omvusel[i][i];
end endgenerate

// Controllers
generate for(i = 0; i < NMVU; i = i + 1) begin: controllerarray
    controller #(
        .BCNTDWN    (BCNTDWN)
    ) controller_unit (
        .clk        (mvu_ext.clk),
        .clr        (controller_clr[i]),
        .start      (mvu_cfg.start[i]),
        .countdown  (mvu_cfg.countdown[i]),
        .step       (step[i]),
        .run        (run[i]),
        .done       (mvu_ext.done[i]),
        .irq        (mvu_ext.irq[i])
    );
end endgenerate


// Address generation modules for input and weight memory
generate for(i = 0; i < NMVU; i = i + 1) begin: inaguarray
    inagu #(
        .BPREC      (BPREC),
        .BDBANKA    (BDBANKA),
        .BWBANKA    (BWBANKA),
        .BWLENGTH   (BLENGTH)
    ) inagu_unit (
        .clk        (mvu_ext.clk),
        .clr        (inagu_clr[i]),
        .en         (run[i]),
        .iprecision (mvu_cfg.iprecision[i]),
        .ijump      (mvu_cfg.ijump[i]),
        .ilength    (mvu_cfg.ilength[i]),
        .ibaseaddr  (mvu_cfg.ibaseaddr[i]),
        .wprecision (mvu_cfg.wprecision[i]),
        .wjump      (mvu_cfg.wjump[i]),
        .wlength    (mvu_cfg.wlength[i]),
        .wbaseaddr  (mvu_cfg.wbaseaddr[i]),
        .zigzag_step_sel(mvu_cfg.zigzag_step_sel[i]),
        .iaddr_out  (rdd_addr[i*BDBANKA +: BDBANKA]),
        .waddr_out  (rdw_addr[i*BWBANKA +: BWBANKA]),
        .imsb       (d_msb[i]),
        .wmsb       (w_msb[i]),
        .sh_out     (agu_sh_out[i]),
        .wagu_on_j  (wagu_on_j[i])
    );
end endgenerate

// Scaler and Bias memory address generation units
generate for(i = 0; i < NMVU; i = i+1) begin: scalerbiasaguarray

    agu #(
        .BWADDR     (BSBANKA),
        .BWLENGTH   (BLENGTH)
    ) scaleragu_unit (
        .clk        (mvu_ext.clk),
        .clr        (scaleragu_clr[i]),
        .step       (scaleragu_step[i]),
        .l          (mvu_cfg.slength[i]),
        .j          (mvu_cfg.sjump[i]),            // TODO: come up with better numbering scheme
        .addr_out   (rds_addr_offset[i]),
        .z_out      (),
        .on_j       ()
    );

    agu #(
        .BWADDR     (BBBANKA),
        .BWLENGTH   (BLENGTH)
    ) biasagu_unit (
        .clk        (mvu_ext.clk),
        .clr        (scaleragu_clr[i]),
        .step       (scaleragu_step[i]),
        .l          (mvu_cfg.blength[i]),
        .j          (mvu_cfg.bjump[i]),            // TODO: come up with better numbering scheme
        .addr_out   (rdb_addr_offset[i]),
        .z_out      (),
        .on_j       ()
    );

    assign rds_addr[i*BSBANKA +: BSBANKA] = mvu_cfg.sbaseaddr[i] + rds_addr_offset[i];
    assign rdb_addr[i*BBBANKA +: BBBANKA] = mvu_cfg.bbaseaddr[i] + rdb_addr_offset[i];

end endgenerate

// Output address generators
generate for(i = 0; i < NMVU; i = i+1) begin:outaguarray
    outagu #(
            .BDBANKA    (BDBANKA)
        ) outaguunit
        (
            .clk        (mvu_ext.clk                            ),
            .clr        (outagu_clr[i]                      ),
            .step       (outstep[i]                         ),
            .load       (outagu_load[i]                     ),
            .baseaddr   (mvu_cfg.obaseaddr[i]),
            .addrout    (wrd_addr[i*BDBANKA  +: BDBANKA]    )
        );
end endgenerate

// Quantizer Controllers
generate for(i = 0; i < NMVU; i = i+1) begin: quantser_ctrlarray
    assign quant_bwout[i*BPREC +: BQBOUT] = mvu_cfg.oprecision[i];
    quantser_ctrl #(
        .BWOUT      (BSCALERP)
    ) quantser_ctrl_unit (
        .clk        (mvu_ext.clk),
        .clr        (quant_ctrl_clr[i]),
        .bwout      (quant_bwout[i*BPREC +: BQBOUT]),
        .start      (quant_start[i]),
        .stall      (quant_stall[i]),
        .load       (quant_load[i]),
        .step       (quant_step[i])
    );
end endgenerate

// Negate the input to the accumulators when one or both data/weights are signed and is on an MSB
assign neg_acc = (mvu_cfg.d_signed & d_msb) ^ (mvu_cfg.w_signed & w_msb);

// Trigger when the shacc should load
generate for(i = 0; i < NMVU; i = i+1) begin: triggers
    assign agu_shacc_done[i] = run[i] && (wagu_on_j[i] & mvu_cfg.shacc_load_sel[i]);
end endgenerate


// Insert delay for accumulator shifter signals to account for number of VVP pipeline stages
generate for(i=0; i < NMVU; i = i+1) begin: ctrl_delayarray

    // TODO: connect the step signals on these shift regs
    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY + 1)
    ) shacc_load_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (mvu_cfg.start[i]),
        .out    (shacc_load_start[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY + 0)
    ) neg_acc_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (neg_acc[i]),
        .out    (neg_acc_dly[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY + 0)
    ) shacc_sh_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (agu_sh_out[i]),
        .out    (shacc_sh[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY + 1)
    ) shacc_acc_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (run_acc[i]),
        .out    (shacc_acc[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY + 1)      // TODO: find a better way to re-time this
    ) acc_done_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (agu_shacc_done[i]),
        .out    (shacc_done[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY)      // TODO: find a better way to re-time this
    ) scaleragu_step_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (agu_shacc_done[i]),
        .out    (scaleragu_step[i])
    );

    shiftreg #(
        .N      (VVPSTAGES + MEMRDLATENCY)      // TODO: find a better way to re-time this
    ) scaleragu_clr_delayarrayunit (
        .clk    (mvu_ext.clk), 
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (mvu_cfg.start[i]),
        .out    (scaleragu_clr_dly[i])
    );

    shiftreg #(
        .N      (SCALERLATENCY+MAXPOOLSTAGES)
    ) maxpool_done_delayarrayunit (
        .clk    (mvu_ext.clk),
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (shacc_done[i]),
        .out    (maxpool_done[i])
    );

    shiftreg #(
        .N      (VVPSTAGES+MEMRDLATENCY+SCALERLATENCY+MAXPOOLSTAGES + 1)
    ) outagu_load_delayarrayunit (
        .clk    (mvu_ext.clk),
        .clr    (~mvu_ext.rst_n),
        .step   (1'b1),
        .in     (mvu_cfg.start[i]),
        .out    (outagu_load[i])
    );

end endgenerate


/*   Cores... */
generate for(i=0;i<NMVU;i=i+1) begin:mvuarray
    mvu #(
            .N              (N),
            .NDBANK         (NDBANK)
        ) mvuunit
        (
            .clk            (mvu_ext.clk                            ),
            .run            (run[i]                                 ),
            .mul_mode       (mvu_cfg.mul_mode[i]                    ),
            .neg_acc        (neg_acc_dly[i]                         ),
            .shacc_clr      (shacc_clr_int[i]                       ),
            .shacc_load     (shacc_load[i]                          ),
            .shacc_acc      (shacc_acc[i]                           ),
            .shacc_sh       (shacc_sh[i]                            ),
            .scaler_clr     (scaler_clr[i]                          ),
            .scaler_b       (mvu_cfg.scaler_b[i]                    ),
            .usescaler_mem  (mvu_cfg.usescaler_mem[i]               ),
            .usebias_mem    (mvu_cfg.usebias_mem[i]                 ),
            .max_en         (mvu_cfg.max_en[i]                      ),
            .max_clr        (mvu_cfg.max_clr[i]                     ),
            .max_pool       (mvu_cfg.max_pool[i]                    ),
            .quant_clr      (quant_clr_int[i]                       ),
            .quant_msbidx   (mvu_cfg.quant_msbidx[i]                ),
            .quant_load     (quant_load[i]                          ),
            .quant_step     (quant_step[i]                          ),
            .rdw_addr       (rdw_addr[i*BWBANKA +: BWBANKA]         ),
            .wrw_addr       (mvu_ext.wrw_addr[i*BWBANKA +: BWBANKA] ),
            .wrw_word       (mvu_ext.wrw_word[i*BWBANKW +: BWBANKW] ),
            .wrw_en         (mvu_ext.wrw_en[i]                      ),
            .rdd_en         (rdd_en[i]                              ),
            .rdd_grnt       (rdd_grnt[i]                            ),
            .rdd_addr       (rdd_addr[i*BDBANKA +: BDBANKA]         ),
            .wrd_en         (wrd_en[i]                              ),
            .wrd_grnt       (wrd_grnt[i]                            ),
            .wrd_addr       (wrd_addr[i*BDBANKA +: BDBANKA]         ),
            .rdi_en         (rdi_en[i]                              ),
            .rdi_grnt       (rdi_grnt[i]                            ),
            .rdi_addr       (rdi_addr[i*BDBANKA +: BDBANKA]         ),
            .rdi_word       (rdi_word[i*BDBANKW +: BDBANKW]         ),
            .wri_en         (wri_en[i]                              ),
            .wri_grnt       (wri_grnt[i]                            ),
            .wri_addr       (wri_addr[i*BDBANKA +: BDBANKA]         ),
            .wri_word       (wri_word[i*BDBANKW +: BDBANKW]         ),
            .rdc_en         (mvu_ext.rdc_en[i]                      ),
            .rdc_grnt       (mvu_ext.rdc_grnt[i]                    ),
            .rdc_addr       (mvu_ext.rdc_addr[i*BDBANKA +: BDBANKA] ),
            .rdc_word       (mvu_ext.rdc_word[i*BDBANKW +: BDBANKW] ),
            .wrc_en         (mvu_ext.wrc_en[i]                      ),
            .wrc_grnt       (mvu_ext.wrc_grnt[i]                    ),
            .wrc_addr       (mvu_ext.wrc_addr[BDBANKA-1: 0]         ),
            .wrc_word       (mvu_ext.wrc_word[BDBANKW-1 : 0]        ),
            .mvu_word_out   (mvu_word_out[i*BDBANKW +: BDBANKW]     ),
            .rds_en         (rds_en[i]                              ),
            .rds_addr       (rds_addr[i*BSBANKA +: BSBANKA]         ),
            .wrs_en         (mvu_ext.wrs_en[i]                      ),
            .wrs_addr       (mvu_ext.wrs_addr                       ),
            .wrs_word       (mvu_ext.wrs_word                       ),
            .rdb_en         (rdb_en[i]                              ),
            .rdb_addr       (rdb_addr[i*BBBANKA +: BBBANKA]         ),
            .wrb_en         (mvu_ext.wrb_en[i]                      ),
            .wrb_addr       (mvu_ext.wrb_addr                       ),
            .wrb_word       (mvu_ext.wrb_word                       )
        );
end endgenerate


/* Module end */
endmodule