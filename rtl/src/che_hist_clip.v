`include "../include.vh"

module che_hist_clip (
  clk ,
  rstn ,

  ul_vld_i ,
  ur_vld_i ,
  bl_vld_i ,
  br_vld_i ,

  ul_express_bin_i ,
  ur_express_bin_i ,
  bl_express_bin_i ,
  br_express_bin_i ,

  ul_hist_i ,
  ur_hist_i ,
  bl_hist_i ,
  br_hist_i ,

  ul_vld_o ,
  ur_vld_o ,
  bl_vld_o ,
  br_vld_o ,

  ul_hist_o ,
  ur_hist_o ,
  bl_hist_o ,
  br_hist_o
);

  input clk ;
  input rstn ;

  input ul_vld_i ;
  input ur_vld_i ;
  input bl_vld_i ;
  input br_vld_i ;

  input [11:0] ul_express_bin_i ;
  input [11:0] ur_express_bin_i ;
  input [11:0] bl_express_bin_i ;
  input [11:0] br_express_bin_i ;

  input [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] ul_hist_i ;
  input [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] ur_hist_i ;
  input [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] bl_hist_i ;
  input [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] br_hist_i ;

  output ul_vld_o ;
  output ur_vld_o ;
  output bl_vld_o ;
  output br_vld_o ;
  output [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] ul_hist_o ;
  output [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] ur_hist_o ;
  output [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] bl_hist_o ;
  output [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] br_hist_o ;

  che_hist_clip_knl che_hist_clip_knl_ul (
    .clk (clk) ,
    .rstn (rstn) ,

    .vld_i (ul_vld_i) ,
    .express_bin_i (ul_express_bin_i) ,
    .hist_i (ul_hist_i) ,

    .vld_o (ul_vld_o) ,
    .hist_o (ul_hist_o)
  );
  che_hist_clip_knl che_hist_clip_knl_ur (
    .clk (clk) ,
    .rstn (rstn) ,

    .vld_i (ur_vld_i) ,
    .express_bin_i (ur_express_bin_i) ,
    .hist_i (ur_hist_i) ,

    .vld_o (ur_vld_o) ,
    .hist_o (ur_hist_o)
  );
  che_hist_clip_knl che_hist_clip_knl_bl (
    .clk (clk) ,
    .rstn (rstn) ,

    .vld_i (bl_vld_i) ,
    .express_bin_i (bl_express_bin_i) ,
    .hist_i (bl_hist_i) ,

    .vld_o (bl_vld_o) ,
    .hist_o (bl_hist_o)
  );
  che_hist_clip_knl che_hist_clip_knl_br (
    .clk (clk) ,
    .rstn (rstn) ,

    .vld_i (br_vld_i) ,
    .express_bin_i (br_express_bin_i) ,
    .hist_i (br_hist_i) ,

    .vld_o (br_vld_o) ,
    .hist_o (br_hist_o)
  );
endmodule