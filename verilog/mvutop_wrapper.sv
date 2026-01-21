module mvutop_wrapper import mvu_pkg::*;(
        MVU_EXT_INTERFACE mvu_ext_if,
        APB apb
);

mvu_pkg::mvu_cfg_signals_t mvu_cfg_shadow;
mvu_pkg::mvu_cfg_signals_t mvu_cfg_live;

mvutop mvu(
    mvu_ext_if.mvu_ext,
    mvu_cfg_live
);

wire [mvu_pkg::APB_ADDR_WIDTH - 1:0] register_adr;
wire [mvu_pkg::BMVUA-1 : 0] mvu_id;
wire apb_write;

assign register_adr  = apb.paddr;
assign mvu_id = register_adr[APB_ADDR_WIDTH-1:12];
assign apb_write = apb.psel && apb.penable && apb.pwrite;

// APB to register conversion
// TODO latches are being used here, flip flops are preferred. Fix this
genvar genvar_mvu_id;

generate for (genvar_mvu_id = 0; genvar_mvu_id < NMVU; genvar_mvu_id = genvar_mvu_id+1) begin
    always_ff @ (posedge mvu_ext_if.clk) begin : always_ff_block
        // APB register write logic
        if (~mvu_ext_if.rst_n) begin : reset // reset all registers to default values
            mvu_cfg_shadow.wbaseaddr[genvar_mvu_id]        <= '0; // base address defaults can be zero
            mvu_cfg_shadow.ibaseaddr[genvar_mvu_id]        <= '0;
            mvu_cfg_shadow.sbaseaddr[genvar_mvu_id]        <= '0;
            mvu_cfg_shadow.bbaseaddr[genvar_mvu_id]        <= '0;
            mvu_cfg_shadow.obaseaddr[genvar_mvu_id]        <= '0;
            mvu_cfg_shadow.wjump[genvar_mvu_id]            <= '{default: '0}; // jumps and lengths for programming AGU's defaults can be zero too
            mvu_cfg_shadow.ijump[genvar_mvu_id]            <= '{default: '0};
            mvu_cfg_shadow.sjump[genvar_mvu_id]            <= '{default: '0};
            mvu_cfg_shadow.bjump[genvar_mvu_id]            <= '{default: '0};
            mvu_cfg_shadow.ojump[genvar_mvu_id]            <= '{default: '0};
            mvu_cfg_shadow.wlength[genvar_mvu_id]          <= '{default: '0};
            mvu_cfg_shadow.ilength[genvar_mvu_id]          <= '{default: '0};
            mvu_cfg_shadow.slength[genvar_mvu_id]          <= '{default: '0};
            mvu_cfg_shadow.blength[genvar_mvu_id]          <= '{default: '0};
            mvu_cfg_shadow.olength[genvar_mvu_id]          <= '{default: '0};
            mvu_cfg_shadow.wprecision[genvar_mvu_id]       <= '0;
            mvu_cfg_shadow.iprecision[genvar_mvu_id]       <= '0;
            mvu_cfg_shadow.oprecision[genvar_mvu_id]       <= '0;
            mvu_cfg_shadow.w_signed[genvar_mvu_id]         <= '0;
            mvu_cfg_shadow.d_signed[genvar_mvu_id]         <= '0;
            mvu_cfg_shadow.max_en[genvar_mvu_id]           <= '0;
            mvu_cfg_shadow.max_clr[genvar_mvu_id]          <= '0;
            mvu_cfg_shadow.max_pool[genvar_mvu_id]         <= '0;
            mvu_cfg_shadow.quant_clr[genvar_mvu_id]        <= '0;
            mvu_cfg_shadow.mul_mode[genvar_mvu_id]         <= '0;
            mvu_cfg_shadow.quant_msbidx[genvar_mvu_id]     <= '0;
            mvu_cfg_shadow.scaler_b[genvar_mvu_id]         <= 32'b1; // default scaler value of 1.0
            mvu_cfg_shadow.shacc_load_sel[genvar_mvu_id]   <= 32'b00001; // TODO this should have no default value as it only makes sense to set it explicitly
            mvu_cfg_shadow.zigzag_step_sel[genvar_mvu_id]  <= 32'b00011;
            mvu_cfg_shadow.omvusel[genvar_mvu_id]          <= 32'(1<<genvar_mvu_id); // by default direct MVU output to itself
            mvu_cfg_shadow.usescaler_mem[genvar_mvu_id]    <= '0; // do not use scaler memory by default, use scaler_b from regmap
            mvu_cfg_shadow.usebias_mem[genvar_mvu_id]      <= '0; // do not use bias memory by default, use zero bias
            
            //mvu_cfg_shadow <= '{default: '0}; // most registers are set to zero // TODO fix
            //mvu_cfg_shadow.shacc_load_sel[genvar_mvu_id]   <= 32'b00001; // TODO this should have no default value as it only makes sense to set it explicitly
            //mvu_cfg_shadow.zigzag_step_sel[genvar_mvu_id]  <= 32'b00011;
            //mvu_cfg_shadow.omvusel[genvar_mvu_id]          <= 32'(1<<genvar_mvu_id); // by default direct MVU output to itself
            //mvu_cfg_shadow.scaler_b[genvar_mvu_id]         <= 32'b1; // default scaler value of 1.0
            // note mvu_cfg_shadow has a few signals that are not used - they are written instantly to live config on a 'start' kick so shadows are not needed
        end : reset
        else if (apb_write && (mvu_id == genvar_mvu_id)) begin : write_logic
            unique case (mvu_pkg::mvu_csr_t'(register_adr[11:0]))
                mvu_pkg::CSR_MVUWBASEPTR : mvu_cfg_shadow.wbaseaddr[mvu_id]  <= apb.pwdata[BBWADDR-1 : 0];
                mvu_pkg::CSR_MVUIBASEPTR : mvu_cfg_shadow.ibaseaddr[mvu_id]  <= apb.pwdata[BBDADDR-1 : 0];
                mvu_pkg::CSR_MVUSBASEPTR : mvu_cfg_shadow.sbaseaddr[mvu_id]  <= apb.pwdata[BSBANKA-1 : 0];
                mvu_pkg::CSR_MVUBBASEPTR : mvu_cfg_shadow.bbaseaddr[mvu_id]  <= apb.pwdata[BBBANKA-1 : 0];
                mvu_pkg::CSR_MVUOBASEPTR : mvu_cfg_shadow.obaseaddr[mvu_id]  <= apb.pwdata[BBDADDR-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_0  : mvu_cfg_shadow.wjump[mvu_id][0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_1  : mvu_cfg_shadow.wjump[mvu_id][1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_2  : mvu_cfg_shadow.wjump[mvu_id][2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_3  : mvu_cfg_shadow.wjump[mvu_id][3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_4  : mvu_cfg_shadow.wjump[mvu_id][4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_0  : mvu_cfg_shadow.ijump[mvu_id][0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_1  : mvu_cfg_shadow.ijump[mvu_id][1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_2  : mvu_cfg_shadow.ijump[mvu_id][2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_3  : mvu_cfg_shadow.ijump[mvu_id][3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_4  : mvu_cfg_shadow.ijump[mvu_id][4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_0  : mvu_cfg_shadow.sjump[mvu_id][0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_1  : mvu_cfg_shadow.sjump[mvu_id][1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_2  : mvu_cfg_shadow.sjump[mvu_id][2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_3  : mvu_cfg_shadow.sjump[mvu_id][3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_4  : mvu_cfg_shadow.sjump[mvu_id][4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_0  : mvu_cfg_shadow.bjump[mvu_id][0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_1  : mvu_cfg_shadow.bjump[mvu_id][1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_2  : mvu_cfg_shadow.bjump[mvu_id][2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_3  : mvu_cfg_shadow.bjump[mvu_id][3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_4  : mvu_cfg_shadow.bjump[mvu_id][4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_0  : mvu_cfg_shadow.ojump[mvu_id][0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_1  : mvu_cfg_shadow.ojump[mvu_id][1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_2  : mvu_cfg_shadow.ojump[mvu_id][2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_3  : mvu_cfg_shadow.ojump[mvu_id][3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_4  : mvu_cfg_shadow.ojump[mvu_id][4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_1: mvu_cfg_shadow.wlength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_2: mvu_cfg_shadow.wlength[mvu_id][2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_3: mvu_cfg_shadow.wlength[mvu_id][3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_4: mvu_cfg_shadow.wlength[mvu_id][4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_1: mvu_cfg_shadow.ilength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_2: mvu_cfg_shadow.ilength[mvu_id][2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_3: mvu_cfg_shadow.ilength[mvu_id][3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_4: mvu_cfg_shadow.ilength[mvu_id][4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_1: mvu_cfg_shadow.slength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_2: mvu_cfg_shadow.slength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_3: mvu_cfg_shadow.slength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_4: mvu_cfg_shadow.slength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_1: mvu_cfg_shadow.blength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_2: mvu_cfg_shadow.blength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_3: mvu_cfg_shadow.blength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_4: mvu_cfg_shadow.blength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_1: mvu_cfg_shadow.olength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_2: mvu_cfg_shadow.olength[mvu_id][2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_3: mvu_cfg_shadow.olength[mvu_id][3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_4: mvu_cfg_shadow.olength[mvu_id][4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUPRECISION: begin
                    mvu_cfg_shadow.wprecision[mvu_id] <= apb.pwdata[BPREC-1 : 0];
                    mvu_cfg_shadow.iprecision[mvu_id] <= apb.pwdata[2*BPREC-1 : BPREC];
                    mvu_cfg_shadow.oprecision[mvu_id] <= apb.pwdata[3*BPREC-1 : 2*BPREC];
                    mvu_cfg_shadow.w_signed[mvu_id]   <= apb.pwdata[24];
                    mvu_cfg_shadow.d_signed[mvu_id]   <= apb.pwdata[25];
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
                    mvu_cfg_shadow.quant_msbidx[mvu_id] <= apb.pwdata[BQMSBIDX-1 : 0];
                end
                mvu_pkg::CSR_MVUSCALER   : begin
                    mvu_cfg_shadow.scaler_b[mvu_id] <= apb.pwdata[BSCALERB-1 : 0];
                end
                mvu_pkg::CSR_MVUCONFIG1  : begin
                    mvu_cfg_shadow.shacc_load_sel[mvu_id]  <= apb.pwdata[NJUMPS-1 : 0];
                    mvu_cfg_shadow.zigzag_step_sel[mvu_id] <= apb.pwdata[2*NJUMPS-1 : NJUMPS];
                end
                mvu_pkg::CSR_MVUOMVUSEL         : mvu_cfg_shadow.omvusel[mvu_id]        <= apb.pwdata[NMVU-1:0];
                mvu_pkg::CSR_MVUUSESCALER_MEM   : mvu_cfg_shadow.usescaler_mem[mvu_id]  <= apb.pwdata[0];
                mvu_pkg::CSR_MVUUSEBIAS_MEM     : mvu_cfg_shadow.usebias_mem[mvu_id]    <= apb.pwdata[0];
            endcase
        end : write_logic
    end : always_ff_block
end endgenerate

// Handlin for live registers
// Special handling for 'start' field: self-clearing
genvar i;
generate for(i=0; i < NMVU; i = i+1) begin
    always @(posedge mvu_ext_if.clk) begin
        if (~mvu_ext_if.rst_n) begin
            mvu_cfg_live <= '{default: '0}; // TODO fix - this should use always_ff but then we are get issues with repeat assignment. Modify the config struct to be for just one MVU
        end else begin
            // If a write to the MVUCOMMAND register occurs for this MVU, copy the shadow register to the live config signals and set the start bit
            // (the start signal will be delayed one cycle to allow the other config signals to propagate first)
            if (apb_write) begin
                if (((mvu_pkg::mvu_csr_t'(register_adr[11:0])) == mvu_pkg::CSR_MVUCOMMAND) && (i==mvu_id)) begin
                    mvu_cfg_live <= mvu_cfg_shadow; // update live config on start
                    mvu_cfg_live.start[i] <= 1'b1; // send start signal (delayed one clock cycle)
                    
                    mvu_cfg_live.countdown[mvu_id] <= apb.pwdata[BCNTDWN-1 : 0];
                    mvu_cfg_live.mul_mode[mvu_id]  <= apb.pwdata[31:30];
                end else begin
                    mvu_cfg_live.start[i] <= 1'b0;
                end
            end else begin
                mvu_cfg_live.start[i] <= 1'b0;
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
