module mvutop_regmap import mvu_pkg::*;(
        MVU_CFG_INTERFACE mvu_cfg_if,
        APB apb
);

// Retrieve clock and reset
wire clk;
wire rst_n;

assign clk = mvu_ext_if.clk;
assign rst_n = mvu_ext_if.rst_n;

// Separate APB address into mvu_id and register address
wire [mvu_pkg::BMVUA-1 : 0] mvu_id;
assign mvu_id = register_adr[APB_ADDR_WIDTH-1:12];

logic [11:0] register_adr;
assign register_adr  = mvu_pkg::mvu_csr_t'(apb.paddr[11:0]); // cast address to CSR enumerated type

// Extract read_en and write_en from APB signals
wire write_en;
wire read_en;
assign write_en = apb.psel && apb.penable && apb.pwrite;
assign read_en = apb.psel && apb.penable && !apb.pwrite;

// wbaseaddr
logic [BWADDR-1:0] wbaseaddr [NMVU-1:0];
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wbaseaddr <= '{default: '0}; // reset all base addresses to 0
    end else if (write_en && register_adr == mvu_pkg::CSR_MVUWBASEPTR) begin
        wbaseaddr[mvu_id] <= apb.pwdata[BBWADDR-1 : 0];
    end else begin
        wbaseaddr <= wbaseaddr; // hold current values on read
    end
end
assign mvu_cfg_if.wbaseaddr = wbaseaddr;

// ibaseaddr
logic [BBDADDR-1:0] ibaseaddr [NMVU-1:0];
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ibaseaddr <= '{default: '0}; // reset to 0 for all MVU's
    end else if (write_en && register_adr == mvu_pkg::CSR_MVUIBASEPTR) begin
        ibaseaddr[mvu_id] <= apb.pwdata[BBDADDR-1 : 0];
    end
end
assign mvu_cfg_if.ibaseaddr = ibaseaddr;


endmodule