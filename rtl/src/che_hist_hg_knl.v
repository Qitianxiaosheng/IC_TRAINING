
`include "../include.vh"
module che_hist_hg_knl(
  clk ,
  rstn ,

  cfg_uclip_i ,
  wr_en_i ,
  dat_i ,
  wr_addr_i ,

  rd_en_i ,
  rd_addr_i ,
  rd_double_flg_i ,

  cl_en_i ,

  vld_s0_o ,
  vld_s1_o ,

  express_bin_s0_o ,
  express_bin_s1_o ,

  hist_s0_o ,
  hist_s1_o
);
  parameter  UCLIP_WD = -1 ;
  localparam TILE_X_NUM = `SIZ_FRA_X / `TILE_SIZ ;

  input clk ;
  input rstn ;

  input [UCLIP_WD-1 :0] cfg_uclip_i ;
  input wr_en_i ;
  input [`DAT_PIX_WD-1 -1:0] dat_i ;
  input [TILE_X_NUM -1:0]wr_addr_i ;

  input rd_en_i ;
  input [TILE_X_NUM-1:0]rd_addr_i ;
  input rd_double_flg_i ;

  input cl_en_i ;

  output reg vld_s0_o ;
  output reg vld_s1_o ;

  output reg [11:0] express_bin_s0_o ;
  output reg [11:0] express_bin_s1_o ;

  output reg [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] hist_s0_o ;
  output reg [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] hist_s1_o ;

  reg [`HIST_BIN_WD*`GRAY_LEVEAL -1:0] hist_mem [TILE_X_NUM-1 :0] ;
  reg [11:0] express_bin_r [TILE_X_NUM-1 :0] ;

  reg cl_en_r ;
  wire cl_comb_w ;
  reg [`LOG2(TILE_X_NUM) -1:0] cnt_cl_r ;
  wire cnt_cl_done_w ;

  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] hist_s0_w ;
  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] hist_s1_w ;
  wire [11:0] express_bin_s0_w ;
  wire [11:0] express_bin_s1_w ;

  genvar gvIdxX ;
  genvar gvIdxY ;
  assign cl_comb_w = cl_en_r || cl_en_i ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cl_en_r <= 'd0 ;
    end
    else begin
      if( cnt_cl_done_w ) begin
        cl_en_r <= 'd0 ;
      end
      else if( cl_en_r ) begin
        cl_en_r <= 'd1 ;
      end
    end
  end
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_cl_r <= 'd0 ;
    end
    else begin
      if( cl_comb_w ) begin
        if( cnt_cl_done_w ) begin
          cnt_cl_r <= 'd0 ;
        end
        else begin
          cnt_cl_r <= cnt_cl_r + 'd1 ;
        end
      end
    end
  end
  assign cnt_cl_done_w = cnt_cl_r == TILE_X_NUM - 'd1 ;

  generate
    for( gvIdxX=0; gvIdxX<TILE_X_NUM; gvIdxX=gvIdxX+'d1 ) begin : writeX_Hist
      wire wr_x_en_w ;
      reg [`GRAY_LEVEAL-1:0] over_flg_r ;
      wire over_flg_w ;
      assign wr_x_en_w = (gvIdxX == wr_addr_i ) && wr_en_i ;
      wire cl_x_en_w ;
      assign cl_x_en_w = (gvIdxX == cnt_cl_r) && cl_comb_w ;
      for( gvIdxY=0; gvIdxY<`GRAY_LEVEAL; gvIdxY=gvIdxY+'d1 ) begin : writeY_Hist
        wire wr_y_en_w ;
        assign wr_y_en_w = ( gvIdxY == dat_i ) && wr_x_en_w ;
        always@( posedge clk or negedge rstn ) begin
          if( !rstn ) begin
            hist_mem[gvIdxX][`HIST_BIN_WD*gvIdxY -1:`HIST_BIN_WD] <= 'd0 ;
            over_flg_r <= 'd0 ;
          end
          else begin
            if( cl_x_en_w ) begin
              hist_mem[gvIdxX][`HIST_BIN_WD*gvIdxY -1:`HIST_BIN_WD] <= 'd0 ;
              over_flg_r[gvIdxY] <= 'd0 ;
            end
            else if( wr_y_en_w ) begin
              if (hist_mem[gvIdxX][`HIST_BIN_WD*gvIdxY -1:`HIST_BIN_WD] >= cfg_uclip_i) begin
                hist_mem[gvIdxX][`HIST_BIN_WD*gvIdxY -1:`HIST_BIN_WD] <= hist_mem[gvIdxX][`HIST_BIN_WD*gvIdxY -1:`HIST_BIN_WD] ;
                over_flg_r[gvIdxY] <= 'd1 ;
              end
              else begin
                hist_mem[gvIdxX][`HIST_BIN_WD*gvIdxY -1:`HIST_BIN_WD] <= hist_mem[gvIdxX][`HIST_BIN_WD*gvIdxY -1:`HIST_BIN_WD] + 'd1 ;
                over_flg_r[gvIdxY] <= 'd0 ;
              end
            end
            else begin
              over_flg_r[gvIdxY] <= 'd0 ;
            end
          end
        end
      end
      assign over_flg_w = |over_flg_r ;
      always@( posedge clk or negedge rstn ) begin
        if( !rstn ) begin
          express_bin_r[gvIdxX] <= 'd0 ;
        end
        else begin
          if( cl_x_en_w ) begin
            express_bin_r[gvIdxX] <= 'd0 ;
          end
          else begin
            if( over_flg_w ) begin
              express_bin_r[gvIdxX] <= express_bin_r[gvIdxX] + 'd1 ;
            end
          end
        end
      end
    end
  endgenerate

  assign hist_s0_w = hist_mem[rd_addr_i];
  assign hist_s1_w = hist_mem[rd_addr_i+1];
  assign express_bin_s0_w = express_bin_r[rd_addr_i] ;
  assign express_bin_s1_w = express_bin_r[rd_addr_i+1];


  always @( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      vld_s0_o <= 'd0 ;
      express_bin_s0_o <= 'd0 ;
      hist_s0_o <= 'd0 ;
    end
    else begin
      vld_s0_o <= rd_en_i ;
      if( rd_en_i ) begin
        express_bin_s0_o <= express_bin_s0_w ;
        hist_s0_o <= hist_s0_w ;
      end
    end
  end

  always @( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      vld_s1_o <= 'd0 ;
      express_bin_s1_o <= 'd0 ;
      hist_s1_o <= 'd0 ;
    end
    else begin
      vld_s1_o <= rd_en_i && rd_double_flg_i ;
      if( rd_en_i && rd_double_flg_i ) begin
        express_bin_s1_o <= express_bin_s1_w ;
        hist_s1_o <= hist_s1_w ;
      end
    end
  end
endmodule