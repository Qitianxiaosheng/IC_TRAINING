`include "../include.vh"

module che_hist_hg (
  clk ,
  rstn ,

  cfg_uclip_i ,

  wr_en_i ,
  dat_i ,
  wr_num_i ,
  wr_addr_i ,

  rd_en_a_i ,
  rd_num_a_i ,
  rd_addr_a_i ,
  rd_double_flg_a_i ,

  rd_en_b_i ,
  rd_num_b_i ,
  rd_addr_b_i ,
  rd_double_flg_b_i ,

  cl_en_c_i ,
  cl_num_c_i ,

  ul_vld_o ,
  ur_vld_o ,
  bl_vld_o ,
  br_vld_o ,

  ul_express_bin_o ,
  ur_express_bin_o ,
  bl_express_bin_o ,
  br_express_bin_o ,

  ul_hist_o ,
  ur_hist_o ,
  bl_hist_o ,
  br_hist_o
);
  parameter  UCLIP_WD = -1 ;

  localparam TILE_X_NUM = `SIZ_FRA_X / `TILE_SIZ ;

  input clk ;
  input rstn ;
  input [UCLIP_WD:0] cfg_uclip_i ;

  input [`DAT_PIX_WD-1 -1:0] dat_i ;

  input wr_en_i ;
  input [1 :0] wr_num_i ;
  input [TILE_X_NUM-1 :0] wr_addr_i ;

  input rd_en_a_i ;
  input [1 :0]rd_num_a_i ;
  input [TILE_X_NUM-1 :0] rd_addr_a_i ;
  input rd_double_flg_a_i ;

  input rd_en_b_i ;
  input [1 :0]rd_num_b_i ;
  input [TILE_X_NUM-1 :0] rd_addr_b_i ;
  input rd_double_flg_b_i ;

  input cl_en_c_i ;
  input [1 :0]  cl_num_c_i ;

  output reg ul_vld_o ;
  output reg ur_vld_o ;
  output reg bl_vld_o ;
  output reg br_vld_o ;

  output reg [11:0] ul_express_bin_o ;
  output reg [11:0] ur_express_bin_o ;
  output reg [11:0] bl_express_bin_o ;
  output reg [11:0] br_express_bin_o ;

  output reg [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] ul_hist_o ;
  output reg [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] ur_hist_o ;
  output reg [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] bl_hist_o ;
  output reg [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] br_hist_o ;

  wire [2:0] vld_s0_o_w ;
  wire [2:0] vld_s1_o_w ;

  wire [11:0] express_bin_s0_o_w [2:0] ;
  wire [11:0] express_bin_s1_o_w [2:0] ;

  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] hist_s0_o_w [2:0] ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] hist_s1_o_w [2:0] ;

  reg  [1:0] rd_num_a_r ;
  reg  [1:0] rd_num_b_r ;

  genvar gvIdx ;

  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_num_a_r <= 'd0 ;
    end
    else begin
      if( rd_en_a_i ) begin
        rd_num_a_r <= rd_num_a_i ;
      end
    end
  end
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_num_b_r <= 'd0 ;
    end
    else begin
      if( rd_en_b_i ) begin
        rd_num_b_r <= rd_num_b_i ;
      end
    end
  end

  generate
    for( gvIdx=0; gvIdx<'d3; gvIdx=gvIdx+1 ) begin : histHgKnl
      wire wr_en_i_w ;
      wire [`DAT_PIX_WD-1 -1:0] dat_i_w ;
      wire [TILE_X_NUM-1 :0] wr_addrt_i_w ;

      wire cl_en_c_i ;
      wire [1:0] cl_num_c_i ;
      wire rd_en_i_w ;
      reg [TILE_X_NUM-1 :0] rd_addr_i_w ;
      reg rd_double_flg_i_w ;

      assign wr_en_i_w = wr_en_i && ( wr_num_i == gvIdx ) ;
      assign dat_i_w = dat_i ;
      assign wr_addrt_i_w = wr_addr_i ;
      assign cl_en_c_i = cl_en_c_i && ( cl_num_c_i == gvIdx ) ;

      assign rd_en_i_w = rd_en_a_i && (rd_num_a_i == gvIdx) || rd_en_b_i && (rd_num_b_i == gvIdx) ;

      always@(*) begin
        if( rd_en_i_w ) begin
          if( rd_en_a_i ) begin
            rd_addr_i_w = rd_addr_a_i ;
            rd_double_flg_i_w = rd_double_flg_a_i ;
          end
          else begin
            rd_addr_i_w = rd_addr_b_i ;
            rd_double_flg_i_w = rd_double_flg_b_i ;
          end
        end
        else begin
          rd_addr_i_w = 'd0 ;
          rd_double_flg_i_w = 'd0 ;
        end
      end

      che_hist_hg_knl #(
        .UCLIP_WD(UCLIP_WD)
      )che_hist_hg_knl(
        .clk (clk) ,
        .rstn (rstn) ,

        .cfg_uclip_i (cfg_uclip_i) ,
        .wr_en_i ( wr_en_i_w ) ,
        .dat_i ( dat_i_w ) ,
        .wr_addr_i ( wr_addrt_i_w ) ,

        .rd_en_i ( rd_en_i_w ) ,
        .rd_addr_i ( rd_addr_i_w ) ,
        .rd_double_flg_i ( rd_double_flg_i_w ) ,

        .cl_en_i ( cl_en_c_i ) ,

        .vld_s0_o ( vld_s0_o_w[gvIdx] ) ,
        .vld_s1_o ( vld_s1_o_w[gvIdx] ) ,

        .express_bin_s0_o ( express_bin_s0_o_w[gvIdx] ) ,
        .express_bin_s1_o ( express_bin_s1_o_w[gvIdx] ) ,

        .hist_s0_o ( hist_s0_o_w[gvIdx] ),
        .hist_s1_o ( hist_s1_o_w[gvIdx] )
      );
    end
  endgenerate

  always@(*)begin
      ul_vld_o = 'd0 ;
      ur_vld_o = 'd0 ;
      ul_express_bin_o = 'd0 ;
      ur_express_bin_o = 'd0 ;
      ul_hist_o = 'd0 ;
      ur_hist_o = 'd0 ;
    case( rd_num_a_r )
      'd0 : begin
        ul_vld_o = vld_s0_o_w[0] ;
        ur_vld_o = vld_s1_o_w[0] ;
        ul_express_bin_o = express_bin_s0_o_w[0] ;
        ur_express_bin_o = express_bin_s1_o_w[0] ;
        ul_hist_o = hist_s0_o_w[0] ;
        ur_hist_o = hist_s1_o_w[0] ;
      end
      'd1 : begin
        ul_vld_o = vld_s0_o_w[1] ;
        ur_vld_o = vld_s1_o_w[1] ;
        ul_express_bin_o = express_bin_s0_o_w[1] ;
        ur_express_bin_o = express_bin_s1_o_w[1] ;
        ul_hist_o = hist_s0_o_w[1] ;
        ur_hist_o = hist_s1_o_w[1] ;
      end
      'd2 : begin
        ul_vld_o = vld_s0_o_w[2] ;
        ur_vld_o = vld_s1_o_w[2] ;
        ul_express_bin_o = express_bin_s0_o_w[2] ;
        ur_express_bin_o = express_bin_s1_o_w[2] ;
        ul_hist_o = hist_s0_o_w[2] ;
        ur_hist_o = hist_s1_o_w[2] ;
      end
    endcase
  end

  always@(*)begin
      bl_vld_o = 'd0 ;
      br_vld_o = 'd0 ;
      bl_express_bin_o = 'd0 ;
      br_express_bin_o = 'd0 ;
      bl_hist_o = 'd0 ;
      br_hist_o = 'd0 ;
    case( rd_num_b_r )
      'd0 : begin
        bl_vld_o = vld_s0_o_w[0] ;
        br_vld_o = vld_s1_o_w[0] ;
        bl_express_bin_o = express_bin_s0_o_w[0] ;
        br_express_bin_o = express_bin_s1_o_w[0] ;
        bl_hist_o = hist_s0_o_w[0] ;
        br_hist_o = hist_s1_o_w[0] ;
      end
      'd1 : begin
        bl_vld_o = vld_s0_o_w[1] ;
        br_vld_o = vld_s1_o_w[1] ;
        bl_express_bin_o = express_bin_s0_o_w[1] ;
        br_express_bin_o = express_bin_s1_o_w[1] ;
        bl_hist_o = hist_s0_o_w[1] ;
        br_hist_o = hist_s1_o_w[1] ;
      end
      'd2 : begin
        bl_vld_o = vld_s0_o_w[2] ;
        br_vld_o = vld_s1_o_w[2] ;
        bl_express_bin_o = express_bin_s0_o_w[2] ;
        br_express_bin_o = express_bin_s1_o_w[2] ;
        bl_hist_o = hist_s0_o_w[2] ;
        br_hist_o = hist_s1_o_w[2] ;
      end
    endcase
  end

endmodule
