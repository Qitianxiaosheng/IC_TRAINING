`include "../include.vh"
module che_cdf_map(
  clk ,
  rstn ,

  ul_vld_i ,
  ur_vld_i ,
  bl_vld_i ,
  br_vld_i ,

  dat_pix_i ,

  ul_hist_i ,
  ur_hist_i ,
  bl_hist_i ,
  br_hist_i ,

  ul_vld_o ,
  ur_vld_o ,
  bl_vld_o ,
  br_vld_o ,

  ul_dat_o ,
  ur_dat_o ,
  bl_dat_o ,
  br_dat_o
);
  input clk ;
  input rstn ;
  input ul_vld_i ;
  input ur_vld_i ;
  input bl_vld_i ;
  input br_vld_i ;
  input [`DAT_PIX_WD-1 -1:0] dat_pix_i ;

  input [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] ul_hist_i ;
  input [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] ur_hist_i ;
  input [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] bl_hist_i ;
  input [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] br_hist_i ;
  output ul_vld_o ;
  output ur_vld_o ;
  output bl_vld_o ;
  output br_vld_o ;
  output [`DAT_PIX_WD -1:0] ul_dat_o ;
  output [`DAT_PIX_WD -1:0] ur_dat_o ;
  output [`DAT_PIX_WD -1:0] bl_dat_o ;
  output [`DAT_PIX_WD -1:0] br_dat_o ;

  che_cdf_map_knl che_cdf_map_knl_ul(
    .clk (clk),
    .rstn (rstn),

    .vld_i (ul_vld_i) ,
    .hist_i (ul_hist_i) ,
    .dat_i (dat_pix_i) ,

    .vld_o (ul_vld_o) ,
    .dat_o (ul_dat_o)
  );
  che_cdf_map_knl che_cdf_map_knl_ur(
    .clk (clk),
    .rstn (rstn),

    .vld_i (ur_vld_i) ,
    .hist_i (ur_hist_i) ,
    .dat_i (dat_pix_i) ,

    .vld_o (ur_vld_o) ,
    .dat_o (ur_dat_o)
  );
  che_cdf_map_knl che_cdf_map_knl_bl(
    .clk (clk),
    .rstn (rstn),

    .vld_i (bl_vld_i) ,
    .hist_i (bl_hist_i) ,
    .dat_i (dat_pix_i) ,

    .vld_o (bl_vld_o) ,
    .dat_o (bl_dat_o)
  );
  che_cdf_map_knl che_cdf_map_knl_br(
    .clk (clk),
    .rstn (rstn),

    .vld_i (br_vld_i) ,
    .hist_i (br_hist_i) ,
    .dat_i (dat_pix_i) ,

    .vld_o (br_vld_o) ,
    .dat_o (br_dat_o)
  );  
endmodule