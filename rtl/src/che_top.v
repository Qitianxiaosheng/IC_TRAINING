`include "../include.vh"

module che_top (
  clk ,
  rstn ,

  cfg_fclip_i ,

  vld_i ,
  dat_i ,

  vld_o ,
  dat_o
);

  localparam FCLIP_FRC_WD = 4 ;
  localparam FCLIP_INT_WD = 4 ;
  localparam UCLIP_TMP_INT_WD = FCLIP_INT_WD + 2 * `LOG2(`TILE_SIZ) - `LOG2(`GRAY_LEVEAL) ;
  localparam UCLIP_WD = UCLIP_TMP_INT_WD ;
  localparam TILE_X_NUM = `SIZ_FRA_X / `TILE_SIZ ;
  localparam TILE_Y_NUM = `SIZ_FRA_Y / `TILE_SIZ ;

  input clk ;
  input rstn ;
  input [FCLIP_INT_WD+FCLIP_FRC_WD-1 :0]cfg_fclip_i ; // <8,4>
  input vld_i ;
  input [`DAT_PIX_WD -1:0] dat_i ;

  output vld_o ;
  output [`DAT_PIX_WD -1:0] dat_o ;

  reg [`DAT_PIX_WD-1 :0] dat_d0_r ;

  wire CTL_vld_i_w ;

  wire [UCLIP_WD-1:0]CTL_cfg_uclip_o_w ;

  wire CTL_wr_buff_en_o_w ;
  wire [1:0]CTL_wr_buff_num_o_w ;

  wire CTL_rd_buff_en_o_w ;
  wire [1:0]CTL_rd_buff_num_o_w ;

  wire CTL_wr_hist_en_o_w ;
  wire [1:0]CTL_wr_hist_num_o_w ;
  wire [TILE_X_NUM-1:0]CTL_wr_hist_addr_o_w ;
  
  wire CTL_rd_hist_en_a_o_w;
  wire [1:0]CTL_rd_hist_num_a_o_w ;
  wire CTL_rd_hist_addr_a_o_w ;
  wire [TILE_X_NUM -1:0] CTL_rd_hist_double_flg_a_o_w ;

  wire CTL_rd_hist_en_b_o_w ;
  wire [1:0] CTL_rd_hist_num_b_o_w ;
  wire [TILE_X_NUM -1:0] CTL_rd_hist_addr_b_o_w ;
  wire CTL_rd_hist_double_flg_b_o_w ;

  wire CTL_cl_hist_en_c_o ;
  wire [1:0] CTL_cl_hist_num_c_o ;

  wire [`LOG2(`TILE_SIZ) -1:0] CTL_pos_x_lft_o ;
  wire [`LOG2(`TILE_SIZ) -1:0] CTL_pos_y_up_o ;

  wire [`LOG2(`TILE_SIZ)*2 -1:0] POS_dat_i_w ;
  wire POS_vld_i_w ;
  
  wire [`LOG2(`TILE_SIZ)*2 -1:0] POS_dat_o_w ;
  wire POS_rdy_o_w ;

  wire BUFFER_wr_buff_en_i_w ;
  wire [`DAT_PIX_WD-1 -1:0] BUFFER_wr_buff_dat_i_w ;
  wire [1:0] BUFFER_wr_buff_num_i_w ;

  wire BUFFER_rd_buff_en_i_w ;
  wire [1:0] BUFFER_rd_buff_num_i_w ;

  wire BUFFER_vld_o_w ;
  wire [`DAT_PIX_WD-1 -1:0] BUFFER_dat_o_w ;

  reg BUFFER_vld_o_d0_r;
  reg [`DAT_PIX_WD-1 -1:0] BUFFER_dat_o_d0_r ;

  wire HIST_wr_en_i_w ;
  wire [`DAT_PIX_WD-1 -1:0] HIST_dat_i_w ;
  wire [1 :0] HIST_wr_num_i_w ;
  wire [TILE_X_NUM-1 :0] HIST_wr_addr_i_w ;

  wire HIST_rd_en_a_i_w ;
  wire [1 :0] HIST_rd_num_a_i_w ;
  wire [TILE_X_NUM-1 :0] HIST_rd_addr_a_i_w ;
  wire HIST_rd_double_flg_a_i_w ;

  wire HIST_rd_en_b_i_w ;
  wire [1 :0] HIST_rd_num_b_i_w ;
  wire [TILE_X_NUM-1 :0] HIST_rd_addr_b_i_w ;
  wire HIST_rd_double_flg_b_i_w ;

  wire HIST_cl_en_c_i_w ;
  wire [1 :0]HIST_cl_num_c_i_w ;

  wire HIST_ul_vld_o_w ;
  wire HIST_ur_vld_o_w ;
  wire HIST_bl_vld_o_w ;
  wire HIST_br_vld_o_w ;

  wire [11:0] HIST_ul_express_bin_o_w ;
  wire [11:0] HIST_ur_express_bin_o_w ;
  wire [11:0] HIST_bl_express_bin_o_w ;
  wire [11:0] HIST_br_express_bin_o_w ;

  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] HIST_ul_hist_o_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] HIST_ur_hist_o_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] HIST_bl_hist_o_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] HIST_br_hist_o_w ;

  wire CLIP_ul_vld_i_w ;
  wire CLIP_ur_vld_i_w ;
  wire CLIP_bl_vld_i_w ;
  wire CLIP_br_vld_i_w ;

  wire [11:0] CLIP_ul_express_bin_i_w ;
  wire [11:0] CLIP_ur_express_bin_i_w ;
  wire [11:0] CLIP_bl_express_bin_i_w ;
  wire [11:0] CLIP_br_express_bin_i_w ;

  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] CLIP_ul_hist_i_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] CLIP_ur_hist_i_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] CLIP_bl_hist_i_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] CLIP_br_hist_i_w ;

  wire CLIP_ul_vld_o_w ;
  wire CLIP_ur_vld_o_w ;
  wire CLIP_bl_vld_o_w ;
  wire CLIP_br_vld_o_w ;

  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] CLIP_ul_hist_o_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] CLIP_ur_hist_o_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] CLIP_bl_hist_o_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] CLIP_br_hist_o_w ;

  wire MAP_ul_vld_i_w ;
  wire MAP_ur_vld_i_w ;
  wire MAP_bl_vld_i_w ;
  wire MAP_br_vld_i_w ;

  wire [`DAT_PIX_WD-1 -1:0] MAP_dat_pix_i_w ;

  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] MAP_ul_hist_i_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] MAP_ur_hist_i_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] MAP_bl_hist_i_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] MAP_br_hist_i_w ;

  wire MAP_ul_vld_o_w ;
  wire MAP_ur_vld_o_w ;
  wire MAP_bl_vld_o_w ;
  wire MAP_br_vld_o_w ;

  wire [`DAT_PIX_WD -1:0] MAP_ul_dat_o_w ;
  wire [`DAT_PIX_WD -1:0] MAP_ur_dat_o_w ;
  wire [`DAT_PIX_WD -1:0] MAP_bl_dat_o_w ;
  wire [`DAT_PIX_WD -1:0] MAP_br_dat_o_w ;

  wire IPL_ul_vld_i ;
  wire IPL_ur_vld_i ;
  wire IPL_bl_vld_i ;
  wire IPL_br_vld_i ;

  wire  [`LOG2(`TILE_SIZ)-1:0] IPL_pos_x_i ;
  wire  [`LOG2(`TILE_SIZ)-1:0] IPL_pos_y_i ;

  wire [`DAT_PIX_WD-1 :0] IPL_ul_dat_i ;
  wire [`DAT_PIX_WD-1 :0] IPL_ur_dat_i ;
  wire [`DAT_PIX_WD-1 :0] IPL_bl_dat_i ;
  wire [`DAT_PIX_WD-1 :0] IPL_br_dat_i ;

  wire IPL_vld_o ;
  wire [`DAT_PIX_WD-1 :0] IPL_dat_o ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      dat_d0_r <= 'd0 ;
    end
    else begin
      if( vld_i )
        dat_d0_r <= dat_i >> 'd1 ;
    end
  end

  assign CTL_vld_i_w = vld_i ;
  che_ctl #(
    .FCLIP_FRC_WD( FCLIP_FRC_WD ) ,
    .FCLIP_INT_WD(FCLIP_INT_WD) ,
    .UCLIP_WD( UCLIP_WD ) ,
    .UCLIP_TMP_INT_WD( UCLIP_TMP_INT_WD )
  )che_ctl (
    .clk (clk),
    .rstn (rstn),

    .cfg_fclip_i (cfg_fclip_i),
    .vld_i ( CTL_vld_i_w ),

    .cfg_uclip_o ( CTL_cfg_uclip_o_w ),

    .wr_buff_en_o ( CTL_wr_buff_en_o_w ),
    .wr_buff_num_o ( CTL_wr_buff_num_o_w ),

    .rd_buff_en_o ( CTL_rd_buff_en_o_w ),
    .rd_buff_num_o ( CTL_rd_buff_num_o_w ),

    .wr_hist_en_o ( CTL_wr_hist_en_o_w ),
    .wr_hist_num_o ( CTL_wr_hist_num_o_w ),
    .wr_hist_addr_o ( CTL_wr_hist_addr_o_w ),
    
    .rd_hist_en_a_o ( CTL_rd_hist_en_a_o_w ),
    .rd_hist_num_a_o ( CTL_rd_hist_num_a_o_w ),
    .rd_hist_addr_a_o ( CTL_rd_hist_addr_a_o_w ),
    .rd_hist_double_flg_a_o ( CTL_rd_hist_double_flg_a_o_w ),

    .rd_hist_en_b_o ( CTL_rd_hist_en_b_o_w ),
    .rd_hist_num_b_o ( CTL_rd_hist_num_b_o_w ),
    .rd_hist_addr_b_o ( CTL_rd_hist_addr_b_o_w ),
    .rd_hist_double_flg_b_o ( CTL_rd_hist_double_flg_b_o_w ),

    .cl_hist_en_c_o ( CTL_cl_hist_en_c_o ),
    .cl_hist_num_c_o ( CTL_cl_hist_num_c_o ),

    .pos_x_lft_o ( CTL_pos_x_lft_o ),
    .pos_y_up_o  ( CTL_pos_y_up_o )
  );
  assign POS_dat_i_w = {CTL_pos_x_lft_o,CTL_pos_y_up_o} ;
  assign POS_vld_i_w = CTL_wr_buff_en_o_w ;
  assign POS_rdy_o_w = BUFFER_vld_o_w ;
  hs_pipe # (
    .DATA_WIDTH(`LOG2(`TILE_SIZ)*2),
    .PIPE_DEPTH(32) ,
    .KONG_REG(0)
  )che_pos_buff(
    .clk ( clk ),
    .rst_n (rstn),
      
    .data_in_vld (POS_vld_i_w),
    .data_in (POS_dat_i_w),
    .data_in_rdy (),
      
    .data_out_vld (),
    .data_out (POS_dat_o_w),
    .data_out_rdy (POS_rdy_o_w)
  );
  assign BUFFER_wr_buff_en_i_w = CTL_wr_buff_en_o_w ;
  assign BUFFER_wr_buff_num_i_w = CTL_wr_buff_num_o_w ;
  assign BUFFER_wr_buff_dat_i_w = dat_d0_r ;
  assign BUFFER_rd_buff_en_i_w = CTL_rd_buff_en_o_w ;
  assign BUFFER_rd_buff_num_i_w = CTL_rd_buff_num_o_w ;
  che_line_buffer che_line_buffer(

    .clk (clk),
    .rstn (rstn),

    .wr_buff_en_i (BUFFER_wr_buff_en_i_w),
    .wr_buff_dat_i (BUFFER_wr_buff_dat_i_w),
    .wr_buff_num_i (BUFFER_wr_buff_num_i_w),

    .rd_buff_en_i (BUFFER_rd_buff_en_i_w),
    .rd_buff_num_i (BUFFER_rd_buff_num_i_w),

    .vld_o (BUFFER_vld_o_w),
    .dat_o (BUFFER_dat_o_w)
  );
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      BUFFER_vld_o_d0_r <= 'd0 ;
      BUFFER_dat_o_d0_r <= 'd0 ;
    end
    else begin
      BUFFER_vld_o_d0_r <= BUFFER_vld_o_w ;
      if( BUFFER_vld_o_w ) begin
        BUFFER_dat_o_d0_r <= BUFFER_dat_o_w ;
      end
    end
  end
  assign HIST_wr_en_i = CTL_wr_hist_en_o_w ;
  assign HIST_dat_i = dat_d0_r ;
  assign HIST_wr_num_i = CTL_wr_hist_num_o_w ;
  assign HIST_wr_addr_i = CTL_wr_hist_addr_o_w ;

  assign HIST_rd_en_a_i = CTL_rd_hist_en_a_o_w ;
  assign HIST_rd_num_a_i = CTL_rd_hist_num_a_o_w ;
  assign HIST_rd_addr_a_i = CTL_rd_hist_addr_a_o_w ;
  assign HIST_rd_double_flg_a_i = CTL_rd_hist_double_flg_a_o_w ;

  assign HIST_rd_en_b_i = CTL_rd_hist_en_b_o_w ;
  assign HIST_rd_num_b_i = CTL_rd_hist_num_b_o_w ;
  assign HIST_rd_addr_b_i = CTL_rd_hist_addr_b_o_w ;
  assign HIST_rd_double_flg_b_i = CTL_rd_hist_double_flg_b_o_w ;

  assign HIST_cl_en_c_i = CTL_cl_hist_en_c_o ;
  assign HIST_cl_num_c_i = CTL_cl_hist_num_c_o ;
  che_hist_hg#(
    .UCLIP_WD( UCLIP_WD )
  )che_hist_hg (
    .clk ( clk ) ,
    .rstn ( rstn ) ,

    .cfg_uclip_i ( CTL_cfg_uclip_o_w ) ,

    .wr_en_i ( HIST_wr_en_i_w ) ,
    .dat_i ( HIST_dat_i_w) ,
    .wr_num_i (HIST_wr_num_i_w) ,
    .wr_addr_i (HIST_wr_addr_i_w) ,

    .rd_en_a_i (HIST_rd_en_a_i_w) ,
    .rd_num_a_i (HIST_rd_num_a_i_w) ,
    .rd_addr_a_i (HIST_rd_addr_a_i_w) ,
    .rd_double_flg_a_i (HIST_rd_double_flg_a_i_w) ,

    .rd_en_b_i (HIST_rd_en_b_i_w) ,
    .rd_num_b_i (HIST_rd_num_b_i_w) ,
    .rd_addr_b_i (HIST_rd_addr_b_i_w) ,
    .rd_double_flg_b_i (HIST_rd_double_flg_b_i_w) ,

    .cl_en_c_i (HIST_cl_en_c_i_w),
    .cl_num_c_i (HIST_cl_num_c_i_w),

    .ul_vld_o (HIST_ul_vld_o_w),
    .ur_vld_o (HIST_ur_vld_o_w),
    .bl_vld_o (HIST_bl_vld_o_w),
    .br_vld_o (HIST_br_vld_o_w),

    .ul_express_bin_o (HIST_ul_express_bin_o_w),
    .ur_express_bin_o (HIST_ur_express_bin_o_w),
    .bl_express_bin_o (HIST_bl_express_bin_o_w),
    .br_express_bin_o (HIST_br_express_bin_o_w),

    .ul_hist_o (HIST_ul_hist_o_w),
    .ur_hist_o (HIST_ur_hist_o_w),
    .bl_hist_o (HIST_bl_hist_o_w),
    .br_hist_o (HIST_br_hist_o_w)
  );
  assign CLIP_ul_vld_i_w = HIST_ul_vld_o_w ;
  assign CLIP_ur_vld_i_w = HIST_ur_vld_o_w ;
  assign CLIP_bl_vld_i_w = HIST_bl_vld_o_w ;
  assign CLIP_br_vld_i_w = HIST_br_vld_o_w ;

  assign CLIP_ul_express_bin_i_w = HIST_ul_express_bin_o_w ;
  assign CLIP_ur_express_bin_i_w = HIST_ur_express_bin_o_w ;
  assign CLIP_bl_express_bin_i_w = HIST_bl_express_bin_o_w ;
  assign CLIP_br_express_bin_i_w = HIST_br_express_bin_o_w ;

  assign CLIP_ul_hist_i_w = HIST_ul_hist_o_w ;
  assign CLIP_ur_hist_i_w = HIST_ur_hist_o_w ;
  assign CLIP_bl_hist_i_w = HIST_bl_hist_o_w ;
  assign CLIP_br_hist_i_w = HIST_br_hist_o_w ;

  che_hist_clip che_hist_clip (
  .clk (clk),
  .rstn (rstn),

  .ul_vld_i (CLIP_ul_vld_i_w),
  .ur_vld_i (CLIP_ur_vld_i_w),
  .bl_vld_i (CLIP_bl_vld_i_w),
  .br_vld_i (CLIP_br_vld_i_w),

  .ul_express_bin_i (CLIP_ul_express_bin_i_w),
  .ur_express_bin_i (CLIP_ur_express_bin_i_w),
  .bl_express_bin_i (CLIP_bl_express_bin_i_w),
  .br_express_bin_i (CLIP_br_express_bin_i_w),

  .ul_hist_i (CLIP_ul_hist_i_w),
  .ur_hist_i (CLIP_ur_hist_i_w),
  .bl_hist_i (CLIP_bl_hist_i_w),
  .br_hist_i (CLIP_br_hist_i_w),

  .ul_vld_o (HIST_ul_vld_o_w),
  .ur_vld_o (HIST_ur_vld_o_w),
  .bl_vld_o (HIST_bl_vld_o_w),
  .br_vld_o (HIST_br_vld_o_w),

  .ul_hist_o (HIST_ul_hist_o_w),
  .ur_hist_o (HIST_ur_hist_o_w),
  .bl_hist_o (HIST_bl_hist_o_w),
  .br_hist_o (HIST_br_hist_o_w)
);
  assign MAP_ul_vld_i_w = HIST_ul_vld_o_w ;
  assign MAP_ur_vld_i_w = HIST_ur_vld_o_w ;
  assign MAP_bl_vld_i_w = HIST_bl_vld_o_w ;
  assign MAP_br_vld_i_w = HIST_br_vld_o_w ;

  assign MAP_dat_i_w = BUFFER_dat_o_d0_r ;

  assign MAP_ul_hist_i_w = HIST_ul_hist_o_w ;
  assign MAP_ur_hist_i_w = HIST_ur_hist_o_w ;
  assign MAP_bl_hist_i_w = HIST_bl_hist_o_w ;
  assign MAP_br_hist_i_w = HIST_br_hist_o_w ;
  che_cdf_map che_cdf_map(
    .clk (clk),
    .rstn (rstn),

    .ul_vld_i (MAP_ul_vld_i_w),
    .ur_vld_i (MAP_ur_vld_i_w),
    .bl_vld_i (MAP_bl_vld_i_w),
    .br_vld_i (MAP_br_vld_i_w),

    .dat_pix_i (MAP_dat_pix_i_w ),

    .ul_hist_i ( MAP_ul_hist_i_w ),
    .ur_hist_i ( MAP_ur_hist_i_w ),
    .bl_hist_i ( MAP_bl_hist_i_w ),
    .br_hist_i ( MAP_br_hist_i_w ),

    .ul_vld_o ( MAP_ul_vld_o_w ),
    .ur_vld_o ( MAP_ur_vld_o_w ),
    .bl_vld_o ( MAP_bl_vld_o_w ),
    .br_vld_o ( MAP_br_vld_o_w ),

    .ul_dat_o ( MAP_ul_dat_o_w ),
    .ur_dat_o ( MAP_ur_dat_o_w ),
    .bl_dat_o ( MAP_bl_dat_o_w ),
    .br_dat_o ( MAP_br_dat_o_w )
  );
  assign IPL_ul_vld_i = MAP_ul_vld_o_w ;
  assign IPL_ur_vld_i = MAP_ur_vld_o_w ;
  assign IPL_bl_vld_i = MAP_bl_vld_o_w ;
  assign IPL_br_vld_i = MAP_br_vld_o_w ;

  assign IPL_pos_x_i = POS_dat_o_w[2*`LOG2(`TILE_SIZ) -1 :`LOG2(`TILE_SIZ)] ;
  assign IPL_pos_y_i = POS_dat_o_w[`LOG2(`TILE_SIZ) -1 :0] ;
  assign IPL_ul_dat_i = MAP_ul_dat_o_w ;
  assign IPL_ur_dat_i = MAP_ur_dat_o_w ;
  assign IPL_bl_dat_i = MAP_bl_dat_o_w ;
  assign IPL_br_dat_i = MAP_br_dat_o_w ;

  che_cmf_ipl che_cmf_ipl (
  .clk (clk),
  .rstn (rstn),

  .ul_vld_i (IPL_ul_vld_i),
  .ur_vld_i (IPL_ur_vld_i),
  .bl_vld_i (IPL_bl_vld_i),
  .br_vld_i (IPL_br_vld_i),

  .pos_x_i (IPL_pos_x_i),
  .pos_y_i (IPL_pos_y_i),

  .ul_dat_i (IPL_ul_dat_i),
  .ur_dat_i (IPL_ur_dat_i),
  .bl_dat_i (IPL_bl_dat_i),
  .br_dat_i (IPL_br_dat_i),

  .vld_o (IPL_vld_o),
  .dat_o (IPL_dat_o)
);

assign vld_o = IPL_vld_o ;
assign dat_o = IPL_dat_o ;
endmodule