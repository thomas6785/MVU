interface MVU_EXT_INTERFACE();
    import mvu_pkg::*;
    logic[          NMVU-1 : 0] done;                               // Indicates if a job is done

    // Weight writing (write only)
    logic[       BWBANKA-1 : 0] wrw_addr;                           // Weight memory: write address
    logic[       BWBANKW-1 : 0] wrw_word;                           // Weight memory: write word
    logic[     BWBANKW/8-1 : 0] wrw_be;                             // Weight memory: write byte enable
    logic[          NMVU-1 : 0] wrw_en;                             // Weight memory: write enable

    // Scaler writing (write only)
    logic[       BSBANKA-1 : 0] wrs_addr;                           // Scaler memory: write address
    logic[       BSBANKW-1 : 0] wrs_word;                           // Scaler memory: write word
    logic[     BSBANKW/8-1 : 0] wrs_be;                             // Scaler memory: write byte enable
    logic[          NMVU-1 : 0] wrs_en;                             // Scaler memory: write enable

    // Bias writing (write only)
    logic[       BBBANKA-1 : 0] wrb_addr;                           // Bias memory: write address
    logic[       BBBANKW-1 : 0] wrb_word;                           // Bias memory: write word
    logic[     BBBANKW/8-1 : 0] wrb_be;                             // Bias memory: write byte enable
    logic[          NMVU-1 : 0] wrb_en;                             // Bias memory: write enable

    // Data memory (write)
    logic[       BDBANKA-1 : 0] wrc_addr;                           // Data memory: controller write address
    logic[       BDBANKW-1 : 0] wrc_word;                           // Data memory: controller write word
    logic[          NMVU-1 : 0] wrc_en;                             // Data memory: controller write enable
    logic[          NMVU-1 : 0] wrc_grnt;                           // Data memory: controller write grant
    // data memory has no byte-enable signal for now (should be added later)

    // Data memory (read)
    logic[       BDBANKA-1 : 0] rdc_addr;                           // Data memory: controller read address
    logic[       BDBANKW-1 : 0] rdc_word [NMVU-1:0];                // Data memory: controller read word
    logic[          NMVU-1 : 0] rdc_en;                             // Data memory: controller read enable
    logic[          NMVU-1 : 0] rdc_grnt;                           // Data memory: controller read grant

modport  mvu_ext (
                           output done,
                           input  wrw_addr,
                           input  wrw_word,
                           input  wrw_be,
                           input  wrw_en,
                           input  rdc_en,
                           output rdc_grnt,
                           input  rdc_addr,
                           output rdc_word,
                           input  wrc_en,
                           output wrc_grnt,
                           input  wrc_addr,
                           input  wrc_word,
                           input  wrs_en,
                           input  wrs_addr,
                           input  wrs_word,
                           input  wrs_be,
                           input  wrb_en,
                           input  wrb_addr,
                           input  wrb_word,
                           input  wrb_be
);
endinterface
