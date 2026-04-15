interface MVU_EXT_INTERFACE();
    import mvu_pkg::*;
    logic[          NMVU-1 : 0] done;                               // Indicates if a job is done
    logic[   BWBANKA_EXT-1 : 0] wrw_addr [NMVU-1:0];                // Weight memory: write address
    logic[            32-1 : 0] wrw_word [NMVU-1:0];                // Weight memory: write word
    logic[          NMVU-1 : 0] wrw_en;                             // Weight memory: write enable
    logic[          NMVU-1 : 0] rdc_en;                             // Data memory: controller read enable
    logic[          NMVU-1 : 0] rdc_grnt;                           // Data memory: controller read grant
    logic[       BDBANKA-1 : 0] rdc_addr [NMVU-1:0];                // Data memory: controller read address
    logic[       BDBANKW-1 : 0] rdc_word [NMVU-1:0];                // Data memory: controller read word
    logic[          NMVU-1 : 0] wrc_en;                             // Data memory: controller write enable
    logic[          NMVU-1 : 0] wrc_grnt;                           // Data memory: controller write grant
    logic[       BDBANKA-1 : 0] wrc_addr;                           // Data memory: controller write address
    logic[       BDBANKW-1 : 0] wrc_word;                           // Data memory: controller write word
    logic[          NMVU-1 : 0] wrs_en;                             // Scaler memory: write enable
    logic[   BSBANKA_EXT-1 : 0] wrs_addr;                           // Scaler memory: write address
    logic[            32-1 : 0] wrs_word;                           // Scaler memory: write word
    logic[          NMVU-1 : 0] wrb_en;                             // Bias memory: write enable
    logic[   BBBANKA_EXT-1 : 0] wrb_addr;                           // Bias memory: write address
    logic[            32-1 : 0] wrb_word;                           // Bias memory: write word

modport  mvu_ext (
                           output done,
                           input  wrw_addr,
                           input  wrw_word,
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
                           input  wrb_en,
                           input  wrb_addr,
                           input  wrb_word
);
endinterface
