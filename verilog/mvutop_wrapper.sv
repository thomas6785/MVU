module mvutop_wrapper import mvu_pkg::*;(
        MVU_EXT_INTERFACE mvu_ext_if,
        APB apb
);
MVU_CFG_INTERFACE mvu_cfg_if();
mvutop mvu(
    mvu_ext_if.mvu_ext,
    mvu_cfg_if.mvu_cfg
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
            mvu_cfg_if.wbaseaddr[genvar_mvu_id]        <= '0; // base address defaults can be zero
            mvu_cfg_if.ibaseaddr[genvar_mvu_id]        <= '0;
            mvu_cfg_if.sbaseaddr[genvar_mvu_id]        <= '0;
            mvu_cfg_if.bbaseaddr[genvar_mvu_id]        <= '0;
            mvu_cfg_if.obaseaddr[genvar_mvu_id]        <= '0;
            mvu_cfg_if.wjump[genvar_mvu_id][0]         <= '0; // jumps and lengths for programming AGU's defaults can be zero too
            mvu_cfg_if.wjump[genvar_mvu_id][1]         <= '0;
            mvu_cfg_if.wjump[genvar_mvu_id][2]         <= '0;
            mvu_cfg_if.wjump[genvar_mvu_id][3]         <= '0;
            mvu_cfg_if.wjump[genvar_mvu_id][4]         <= '0;
            mvu_cfg_if.ijump[genvar_mvu_id][0]         <= '0;
            mvu_cfg_if.ijump[genvar_mvu_id][1]         <= '0;
            mvu_cfg_if.ijump[genvar_mvu_id][2]         <= '0;
            mvu_cfg_if.ijump[genvar_mvu_id][3]         <= '0;
            mvu_cfg_if.ijump[genvar_mvu_id][4]         <= '0;
            mvu_cfg_if.sjump[genvar_mvu_id][0]         <= '0;
            mvu_cfg_if.sjump[genvar_mvu_id][1]         <= '0;
            mvu_cfg_if.sjump[genvar_mvu_id][2]         <= '0;
            mvu_cfg_if.sjump[genvar_mvu_id][3]         <= '0;
            mvu_cfg_if.sjump[genvar_mvu_id][4]         <= '0;
            mvu_cfg_if.bjump[genvar_mvu_id][0]         <= '0;
            mvu_cfg_if.bjump[genvar_mvu_id][1]         <= '0;
            mvu_cfg_if.bjump[genvar_mvu_id][2]         <= '0;
            mvu_cfg_if.bjump[genvar_mvu_id][3]         <= '0;
            mvu_cfg_if.bjump[genvar_mvu_id][4]         <= '0;
            mvu_cfg_if.ojump[genvar_mvu_id][0]         <= '0;
            mvu_cfg_if.ojump[genvar_mvu_id][1]         <= '0;
            mvu_cfg_if.ojump[genvar_mvu_id][2]         <= '0;
            mvu_cfg_if.ojump[genvar_mvu_id][3]         <= '0;
            mvu_cfg_if.ojump[genvar_mvu_id][4]         <= '0;
            mvu_cfg_if.wlength[genvar_mvu_id][1]       <= '0;
            mvu_cfg_if.wlength[genvar_mvu_id][2]       <= '0;
            mvu_cfg_if.wlength[genvar_mvu_id][3]       <= '0;
            mvu_cfg_if.wlength[genvar_mvu_id][4]       <= '0;
            mvu_cfg_if.ilength[genvar_mvu_id][1]       <= '0;
            mvu_cfg_if.ilength[genvar_mvu_id][2]       <= '0;
            mvu_cfg_if.ilength[genvar_mvu_id][3]       <= '0;
            mvu_cfg_if.ilength[genvar_mvu_id][4]       <= '0;
            mvu_cfg_if.slength[genvar_mvu_id][1]       <= '0;
            mvu_cfg_if.slength[genvar_mvu_id][2]       <= '0;
            mvu_cfg_if.slength[genvar_mvu_id][3]       <= '0;
            mvu_cfg_if.slength[genvar_mvu_id][4]       <= '0;
            mvu_cfg_if.blength[genvar_mvu_id][1]       <= '0;
            mvu_cfg_if.blength[genvar_mvu_id][2]       <= '0;
            mvu_cfg_if.blength[genvar_mvu_id][3]       <= '0;
            mvu_cfg_if.blength[genvar_mvu_id][4]       <= '0;
            mvu_cfg_if.olength[genvar_mvu_id][1]       <= '0;
            mvu_cfg_if.olength[genvar_mvu_id][2]       <= '0;
            mvu_cfg_if.olength[genvar_mvu_id][3]       <= '0;
            mvu_cfg_if.olength[genvar_mvu_id][4]       <= '0;
            mvu_cfg_if.wprecision[genvar_mvu_id]       <= '0;
            mvu_cfg_if.iprecision[genvar_mvu_id]       <= '0;
            mvu_cfg_if.oprecision[genvar_mvu_id]       <= '0;
            mvu_cfg_if.w_signed[genvar_mvu_id]         <= '0;
            mvu_cfg_if.d_signed[genvar_mvu_id]         <= '0;
            mvu_cfg_if.countdown[genvar_mvu_id]        <= '0;
            mvu_cfg_if.max_en[genvar_mvu_id]           <= '0;
            mvu_cfg_if.max_clr[genvar_mvu_id]          <= '0;
            mvu_cfg_if.max_pool[genvar_mvu_id]         <= '0;
            mvu_cfg_if.quant_clr[genvar_mvu_id]        <= '0;
            mvu_cfg_if.mul_mode[genvar_mvu_id]         <= '0;
            mvu_cfg_if.quant_msbidx[genvar_mvu_id]     <= '0;
            mvu_cfg_if.scaler_b[genvar_mvu_id]         <= 32'b1; // default scaler value of 1.0
            mvu_cfg_if.shacc_load_sel[genvar_mvu_id]   <= 32'b00001; // TODO this should have no default value as it only makes sense to set it explicitly
            mvu_cfg_if.zigzag_step_sel[genvar_mvu_id]  <= 32'b00011;
            mvu_cfg_if.omvusel[genvar_mvu_id]          <= 32'(1<<genvar_mvu_id); // by default direct MVU output to itself
            mvu_cfg_if.usescaler_mem[genvar_mvu_id]    <= '0; // do not use scaler memory by default, use scaler_b from regmap
            mvu_cfg_if.usebias_mem[genvar_mvu_id]      <= '0; // do not use bias memory by default, use zero bias
        end : reset
        else if (apb_write && (mvu_id == genvar_mvu_id)) begin : write_logic
            unique case (mvu_pkg::mvu_csr_t'(register_adr[11:0]))
                mvu_pkg::CSR_MVUWBASEPTR : mvu_cfg_if.wbaseaddr[mvu_id]  <= apb.pwdata[BBWADDR-1 : 0];
                mvu_pkg::CSR_MVUIBASEPTR : mvu_cfg_if.ibaseaddr[mvu_id]  <= apb.pwdata[BBDADDR-1 : 0];
                mvu_pkg::CSR_MVUSBASEPTR : mvu_cfg_if.sbaseaddr[mvu_id]  <= apb.pwdata[BSBANKA-1 : 0];
                mvu_pkg::CSR_MVUBBASEPTR : mvu_cfg_if.bbaseaddr[mvu_id]  <= apb.pwdata[BBBANKA-1 : 0];
                mvu_pkg::CSR_MVUOBASEPTR : mvu_cfg_if.obaseaddr[mvu_id]  <= apb.pwdata[BBDADDR-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_0  : mvu_cfg_if.wjump[mvu_id][0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_1  : mvu_cfg_if.wjump[mvu_id][1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_2  : mvu_cfg_if.wjump[mvu_id][2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_3  : mvu_cfg_if.wjump[mvu_id][3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWJUMP_4  : mvu_cfg_if.wjump[mvu_id][4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_0  : mvu_cfg_if.ijump[mvu_id][0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_1  : mvu_cfg_if.ijump[mvu_id][1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_2  : mvu_cfg_if.ijump[mvu_id][2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_3  : mvu_cfg_if.ijump[mvu_id][3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUIJUMP_4  : mvu_cfg_if.ijump[mvu_id][4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_0  : mvu_cfg_if.sjump[mvu_id][0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_1  : mvu_cfg_if.sjump[mvu_id][1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_2  : mvu_cfg_if.sjump[mvu_id][2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_3  : mvu_cfg_if.sjump[mvu_id][3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUSJUMP_4  : mvu_cfg_if.sjump[mvu_id][4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_0  : mvu_cfg_if.bjump[mvu_id][0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_1  : mvu_cfg_if.bjump[mvu_id][1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_2  : mvu_cfg_if.bjump[mvu_id][2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_3  : mvu_cfg_if.bjump[mvu_id][3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUBJUMP_4  : mvu_cfg_if.bjump[mvu_id][4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_0  : mvu_cfg_if.ojump[mvu_id][0]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_1  : mvu_cfg_if.ojump[mvu_id][1]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_2  : mvu_cfg_if.ojump[mvu_id][2]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_3  : mvu_cfg_if.ojump[mvu_id][3]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUOJUMP_4  : mvu_cfg_if.ojump[mvu_id][4]   <= apb.pwdata[BJUMP-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_1: mvu_cfg_if.wlength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_2: mvu_cfg_if.wlength[mvu_id][2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_3: mvu_cfg_if.wlength[mvu_id][3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUWLENGTH_4: mvu_cfg_if.wlength[mvu_id][4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_1: mvu_cfg_if.ilength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_2: mvu_cfg_if.ilength[mvu_id][2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_3: mvu_cfg_if.ilength[mvu_id][3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUILENGTH_4: mvu_cfg_if.ilength[mvu_id][4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_1: mvu_cfg_if.slength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_2: mvu_cfg_if.slength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_3: mvu_cfg_if.slength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUSLENGTH_4: mvu_cfg_if.slength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_1: mvu_cfg_if.blength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_2: mvu_cfg_if.blength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_3: mvu_cfg_if.blength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUBLENGTH_4: mvu_cfg_if.blength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_1: mvu_cfg_if.olength[mvu_id][1] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_2: mvu_cfg_if.olength[mvu_id][2] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_3: mvu_cfg_if.olength[mvu_id][3] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUOLENGTH_4: mvu_cfg_if.olength[mvu_id][4] <= apb.pwdata[BLENGTH-1 : 0];
                mvu_pkg::CSR_MVUPRECISION: begin
                    mvu_cfg_if.wprecision[mvu_id] <= apb.pwdata[BPREC-1 : 0];
                    mvu_cfg_if.iprecision[mvu_id] <= apb.pwdata[2*BPREC-1 : BPREC];
                    mvu_cfg_if.oprecision[mvu_id] <= apb.pwdata[3*BPREC-1 : 2*BPREC];
                    mvu_cfg_if.w_signed[mvu_id]   <= apb.pwdata[24];
                    mvu_cfg_if.d_signed[mvu_id]   <= apb.pwdata[25];
                end
                mvu_pkg::CSR_MVUSTATUS   : begin
                    $display("APB attempted write to read-only register CSR_MVUSTATUS!");
                end
                mvu_pkg::CSR_MVUCOMMAND  : begin
                    mvu_cfg_if.countdown[mvu_id] <= apb.pwdata[BCNTDWN-1 : 0];
                    mvu_cfg_if.max_en[mvu_id]    <= apb.pwdata[29];
                    mvu_cfg_if.max_clr[mvu_id]   <= 0;
                    mvu_cfg_if.max_pool[mvu_id]  <= 0;
                    mvu_cfg_if.quant_clr[mvu_id] <= 0;
                    mvu_cfg_if.mul_mode[mvu_id]  <= apb.pwdata[31:30];
                end
                mvu_pkg::CSR_MVUQUANT    : begin
                    mvu_cfg_if.quant_msbidx[mvu_id] <= apb.pwdata[BQMSBIDX-1 : 0];
                end
                mvu_pkg::CSR_MVUSCALER   : begin
                    mvu_cfg_if.scaler_b[mvu_id] <= apb.pwdata[BSCALERB-1 : 0];
                    // mvu_cfg_if.scaler1_b[mvu_id] = apb.pwdata[BSCALERB-1 : 0];
                    // mvu_cfg_if.scaler2_b[mvu_id] = apb.pwdata[2*BSCALERB-1 : BSCALERB];
                end
                mvu_pkg::CSR_MVUCONFIG1  : begin
                    mvu_cfg_if.shacc_load_sel[mvu_id]  <= apb.pwdata[NJUMPS-1 : 0];
                    mvu_cfg_if.zigzag_step_sel[mvu_id] <= apb.pwdata[2*NJUMPS-1 : NJUMPS];
                end
                mvu_pkg::CSR_MVUOMVUSEL         : mvu_cfg_if.omvusel[mvu_id]        <= apb.pwdata[NMVU-1:0];
                mvu_pkg::CSR_MVUUSESCALER_MEM   : mvu_cfg_if.usescaler_mem[mvu_id]  <= apb.pwdata[0];
                mvu_pkg::CSR_MVUUSEBIAS_MEM     : mvu_cfg_if.usebias_mem[mvu_id]    <= apb.pwdata[0];
            endcase
        end : write_logic
    end : always_ff_block
end endgenerate

// Special handlin for 'start' field: self-clearing
genvar i;
generate for(i=0; i < NMVU; i = i+1) begin
    always @(posedge mvu_ext_if.clk) begin
        if (~mvu_ext_if.rst_n) begin
            mvu_ext_if.start[i] <= 1'b0;
        end else begin
            if (apb_write) begin
                if (((mvu_pkg::mvu_csr_t'(register_adr[11:0])) == mvu_pkg::CSR_MVUCOMMAND) && (i==mvu_id)) begin
                    mvu_ext_if.start[i] <= 1'b1;
                end else begin
                    mvu_ext_if.start[i] <= 1'b0;
                end
            end else begin
                mvu_ext_if.start[i] <= 1'b0;
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
        mvu_pkg::CSR_MVUWBASEPTR           : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUIBASEPTR           : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSBASEPTR           : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUBBASEPTR           : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOBASEPTR           : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUWJUMP_0            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUWJUMP_1            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUWJUMP_2            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUWJUMP_3            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUWJUMP_4            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUIJUMP_0            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUIJUMP_1            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUIJUMP_2            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUIJUMP_3            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUIJUMP_4            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSJUMP_0            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSJUMP_1            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSJUMP_2            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSJUMP_3            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSJUMP_4            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUBJUMP_0            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUBJUMP_1            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUBJUMP_2            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUBJUMP_3            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUBJUMP_4            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOJUMP_0            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOJUMP_1            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOJUMP_2            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOJUMP_3            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOJUMP_4            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUWLENGTH_0          : apb.prdata = '0; // write-only register TODO investigate why the register is not used? there's no write implementation
        mvu_pkg::CSR_MVUWLENGTH_1          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUWLENGTH_2          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUWLENGTH_3          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUWLENGTH_4          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUILENGTH_1          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUILENGTH_2          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUILENGTH_3          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUILENGTH_4          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSLENGTH_1          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSLENGTH_2          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSLENGTH_3          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSLENGTH_4          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUBLENGTH_1          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUBLENGTH_2          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUBLENGTH_3          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUBLENGTH_4          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOLENGTH_1          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOLENGTH_2          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOLENGTH_3          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOLENGTH_4          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUPRECISION          : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUCOMMAND            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUQUANT              : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSCALER             : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUCONFIG1            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUOMVUSEL            : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUUSESCALER_MEM      : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUUSEBIAS_MEM        : apb.prdata = '0; // write-only register
        mvu_pkg::CSR_MVUSTATUS             : apb.prdata = {31'b0, mvu_ext_if.done[mvu_id]}; // read-only register
        default : apb.prdata = '0; // invalid register address
    endcase
end

endmodule
