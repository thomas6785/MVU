module mvutop_wrapper import mvu_pkg::*;import apb_pkg::*;(
        MVU_EXT_INTERFACE mvu_ext_if,
        APB apb
);

mvutop mvu(
    mvu_ext_if.mvu_ext,
    mvu_cfg_if.mvu_cfg
);

// Instantiate the MVU Config interface, which has static signals for each CSR register
MVU_CFG_INTERFACE mvu_cfg_if();

// Instantiate the regmap which handles APB transactions and maps them to the MVU config interface
mvutop_regmap mvutop_regmap_inst (
    .apb         (apb),
    .mvu_cfg_if  (mvu_cfg_if)
);

endmodule