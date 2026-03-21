module mvutop_wrapper import mvu_pkg::*;(
    input logic clk,
    input logic rst_n,
    output logic [NMVU-1:0] irq,
    MVU_EXT_INTERFACE mvu_ext_if,
    APB apb
);

mvu_pkg::mvu_cfg_signals_t mvu_cfg_shadow [NMVU-1:0];
mvu_pkg::mvu_cfg_signals_t mvu_cfg_live [NMVU-1:0];

mvutop mvu(
    .clk(clk),
    .rst_n(rst_n),
    .irq(irq),
    .mvu_ext(mvu_ext_if.mvu_ext),
    .mvu_cfg(mvu_cfg_live)
);

wire [mvu_pkg::APB_ADDR_WIDTH - 1:0] register_adr;
wire [mvu_pkg::BMVUA-1 : 0] mvu_id;
wire apb_write;

assign register_adr  = apb.paddr;
assign mvu_id = register_adr[APB_ADDR_WIDTH-1:12];
assign apb_write = apb.psel && apb.penable && apb.pwrite;

// APB to register conversion
genvar genvar_mvu_id;

generate for (genvar_mvu_id = 0; genvar_mvu_id < NMVU; genvar_mvu_id = genvar_mvu_id+1) begin
    always_ff @ (posedge clk) begin : always_ff_block
        // APB register write logic
        if (~rst_n) begin : reset // reset all registers to default values
            mvu_cfg_shadow[genvar_mvu_id]                  <= '{default: '0}; // most registers are set to zero

            // Some default values, TODO remove these, they should really be set by the software
            mvu_cfg_shadow[genvar_mvu_id].shacc_load_sel   <= 32'b00001;
            mvu_cfg_shadow[genvar_mvu_id].zigzag_step_sel  <= 32'b01111;
            mvu_cfg_shadow[genvar_mvu_id].omvusel          <= 32'(1<<genvar_mvu_id); // by default direct MVU output to itself
            mvu_cfg_shadow[genvar_mvu_id].scaler_b         <= 32'b1; // default scaler value of 1.0
            // note mvu_cfg_shadow has a few signals that are not used - they are written instantly to live config on a 'start' kick so shadows are not needed. Synthesis tools should be able to recognise this and strip them out
        end : reset
        else if (apb_write && (mvu_id == genvar_mvu_id)) begin : write_logic
            unique case (mvu_pkg::mvu_csr_t'(register_adr[11:0]))
                mvu_pkg::CSR_MVUWBASEPTR : mvu_cfg_shadow[genvar_mvu_id].wbaseaddr  <= apb.pwdata[BBWADDR-1 : 0];
                mvu_pkg::CSR_MVUIBASEPTR : mvu_cfg_shadow[genvar_mvu_id].ibaseaddr  <= apb.pwdata[BBDADDR-1 : 0];
                mvu_pkg::CSR_MVUSBASEPTR : mvu_cfg_shadow[genvar_mvu_id].sbaseaddr  <= apb.pwdata[BSBANKA-1 : 0];
                mvu_pkg::CSR_MVUBBASEPTR : mvu_cfg_shadow[genvar_mvu_id].bbaseaddr  <= apb.pwdata[BBBANKA-1 : 0];
                mvu_pkg::CSR_MVUOBASEPTR : mvu_cfg_shadow[genvar_mvu_id].obaseaddr  <= apb.pwdata[BBDADDR-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_0  : mvu_cfg_shadow[genvar_mvu_id].wjump[0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_1  : mvu_cfg_shadow[genvar_mvu_id].wjump[1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_2  : mvu_cfg_shadow[genvar_mvu_id].wjump[2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_3  : mvu_cfg_shadow[genvar_mvu_id].wjump[3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_4  : mvu_cfg_shadow[genvar_mvu_id].wjump[4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_0  : mvu_cfg_shadow[genvar_mvu_id].ijump[0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_1  : mvu_cfg_shadow[genvar_mvu_id].ijump[1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_2  : mvu_cfg_shadow[genvar_mvu_id].ijump[2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_3  : mvu_cfg_shadow[genvar_mvu_id].ijump[3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_4  : mvu_cfg_shadow[genvar_mvu_id].ijump[4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_0  : mvu_cfg_shadow[genvar_mvu_id].sjump[0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_1  : mvu_cfg_shadow[genvar_mvu_id].sjump[1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_2  : mvu_cfg_shadow[genvar_mvu_id].sjump[2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_3  : mvu_cfg_shadow[genvar_mvu_id].sjump[3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_4  : mvu_cfg_shadow[genvar_mvu_id].sjump[4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_0  : mvu_cfg_shadow[genvar_mvu_id].bjump[0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_1  : mvu_cfg_shadow[genvar_mvu_id].bjump[1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_2  : mvu_cfg_shadow[genvar_mvu_id].bjump[2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_3  : mvu_cfg_shadow[genvar_mvu_id].bjump[3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_4  : mvu_cfg_shadow[genvar_mvu_id].bjump[4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_0  : mvu_cfg_shadow[genvar_mvu_id].ojump[0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_1  : mvu_cfg_shadow[genvar_mvu_id].ojump[1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_2  : mvu_cfg_shadow[genvar_mvu_id].ojump[2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_3  : mvu_cfg_shadow[genvar_mvu_id].ojump[3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_4  : mvu_cfg_shadow[genvar_mvu_id].ojump[4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_1: mvu_cfg_shadow[genvar_mvu_id].wlength[1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_2: mvu_cfg_shadow[genvar_mvu_id].wlength[2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_3: mvu_cfg_shadow[genvar_mvu_id].wlength[3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_4: mvu_cfg_shadow[genvar_mvu_id].wlength[4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_1: mvu_cfg_shadow[genvar_mvu_id].ilength[1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_2: mvu_cfg_shadow[genvar_mvu_id].ilength[2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_3: mvu_cfg_shadow[genvar_mvu_id].ilength[3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_4: mvu_cfg_shadow[genvar_mvu_id].ilength[4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_1: mvu_cfg_shadow[genvar_mvu_id].slength[1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_2: mvu_cfg_shadow[genvar_mvu_id].slength[2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_3: mvu_cfg_shadow[genvar_mvu_id].slength[3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_4: mvu_cfg_shadow[genvar_mvu_id].slength[4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_1: mvu_cfg_shadow[genvar_mvu_id].blength[1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_2: mvu_cfg_shadow[genvar_mvu_id].blength[2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_3: mvu_cfg_shadow[genvar_mvu_id].blength[3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_4: mvu_cfg_shadow[genvar_mvu_id].blength[4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_1: mvu_cfg_shadow[genvar_mvu_id].olength[1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_2: mvu_cfg_shadow[genvar_mvu_id].olength[2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_3: mvu_cfg_shadow[genvar_mvu_id].olength[3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_4: mvu_cfg_shadow[genvar_mvu_id].olength[4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUPRECISION: begin
                    mvu_cfg_shadow[genvar_mvu_id].wprecision <= apb.pwdata[BPREC-1 : 0];
                    mvu_cfg_shadow[genvar_mvu_id].iprecision <= apb.pwdata[2*BPREC-1 : BPREC];
                    mvu_cfg_shadow[genvar_mvu_id].oprecision <= apb.pwdata[3*BPREC-1 : 2*BPREC];
                    mvu_cfg_shadow[genvar_mvu_id].w_signed   <= apb.pwdata[24];
                    mvu_cfg_shadow[genvar_mvu_id].d_signed   <= apb.pwdata[25];
                end
                mvu_pkg::CSR_MVUSTATUS   : begin
                    $display("APB attempted write to read-only register CSR_MVUSTATUS!");
                end
                mvu_pkg::CSR_MVUCOMMAND  : begin
                    // CSR_MVUCOMMAND is the only register without shadow regs
                    // because it implicitly kicks off the MVU on write
                    // handled separately below
                end
                mvu_pkg::CSR_MVUQUANT    : begin
                    mvu_cfg_shadow[genvar_mvu_id].quant_msbidx <= apb.pwdata[BQMSBIDX-1 : 0];
                end
                mvu_pkg::CSR_MVUSCALER   : begin
                    mvu_cfg_shadow[genvar_mvu_id].scaler_b <= apb.pwdata[BSCALERB-1 : 0];
                end
                mvu_pkg::CSR_MVUCONFIG1  : begin
                    mvu_cfg_shadow[genvar_mvu_id].shacc_load_sel  <= apb.pwdata[NJUMPS-1 : 0];
                    mvu_cfg_shadow[genvar_mvu_id].zigzag_step_sel <= apb.pwdata[2*NJUMPS-1 : NJUMPS];
                end
                mvu_pkg::CSR_MVUOMVUSEL         : mvu_cfg_shadow[genvar_mvu_id].omvusel        <= apb.pwdata[NMVU-1:0];
                mvu_pkg::CSR_MVUUSESCALER_MEM   : mvu_cfg_shadow[genvar_mvu_id].usescaler_mem  <= apb.pwdata[0];
                mvu_pkg::CSR_MVUUSEBIAS_MEM     : mvu_cfg_shadow[genvar_mvu_id].usebias_mem    <= apb.pwdata[0];
            endcase
        end : write_logic
    end : always_ff_block
end endgenerate

// Handling for live registers
// Special handling for 'start' field: self-clearing
genvar i;
generate for(i=0; i < NMVU; i = i+1) begin
    always @(posedge clk) begin
        if (~rst_n) begin
            mvu_cfg_live[i] <= '{default: '0}; // reset to all zeros
        end else begin
            // If a write to the MVUCOMMAND register occurs for this MVU, copy the shadow register to the live config signals and set the start bit
            // (the start signal will be delayed one cycle to allow the other config signals to propagate first)
            if (apb_write) begin
                if (((mvu_pkg::mvu_csr_t'(register_adr[11:0])) == mvu_pkg::CSR_MVUCOMMAND) && (i==mvu_id)) begin
                    mvu_cfg_live[i] <= mvu_cfg_shadow[i]; // update live config on start
                    mvu_cfg_live[i].start <= 1'b1; // send start signal (delayed one clock cycle)
                    
                    mvu_cfg_live[i].countdown <= apb.pwdata[BCNTDWN-1 : 0];
                    mvu_cfg_live[i].mul_mode  <= apb.pwdata[31:30];
                end else begin
                    mvu_cfg_live[i].start <= 1'b0;
                end
            end else begin
                mvu_cfg_live[i].start <= 1'b0;
            end
        end
    end
end endgenerate

// assume we are always ready to accept APB transfers
assign apb.pready  = 1'b1;

// currently no logic for detecting illegal transactions
assign apb.pslverr = 1'b0; // TODO detect illegal addresses, ro writes, and wo reads

// APB read MUX
always_comb begin
    unique case (mvu_pkg::mvu_csr_t'(register_adr[11:0])) // TODO would be better to only update on apb_read for power reaosns, but there are no read-write registers atm anyway
        mvu_pkg::CSR_MVUWLENGTH_0          : apb.prdata = '0; // write-only register TODO investigate why the register is not used? there's no write implementation
        mvu_pkg::CSR_MVUSTATUS             : apb.prdata = {31'b0, mvu_ext_if.done[mvu_id]}; // read-only register
        default : apb.prdata = '0; // invalid register address
    endcase
end

endmodule
