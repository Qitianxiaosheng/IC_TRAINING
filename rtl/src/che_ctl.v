`include "../include.vh"

module che_ctl (
  clk ,
  rstn ,

  cfg_fclip_i ,
  vld_i ,

  cfg_uclip_o ,

  wr_buff_en_o ,
  wr_buff_num_o ,

  rd_buff_en_o ,
  rd_buff_num_o ,

  wr_hist_en_o ,
  wr_hist_num_o ,
  wr_hist_addr_o ,
  
  rd_hist_en_a_o ,
  rd_hist_num_a_o ,
  rd_hist_addr_a_o ,
  rd_hist_double_flg_a_o ,

  rd_hist_en_b_o ,
  rd_hist_num_b_o ,
  rd_hist_addr_b_o ,
  rd_hist_double_flg_b_o ,

  cl_hist_en_c_o ,
  cl_hist_num_c_o ,

  pos_x_lft_o ,
  pos_y_up_o
);
  parameter  FCLIP_FRC_WD = -1 ;
  parameter  FCLIP_INT_WD = -1 ;
  parameter  UCLIP_WD = -1 ;
  parameter  UCLIP_TMP_INT_WD = -1 ;
  localparam TILE_X_NUM = `SIZ_FRA_X / `TILE_SIZ ;
  localparam TILE_Y_NUM = `SIZ_FRA_Y / `TILE_SIZ ;

  // input/output
  input clk ;
  input rstn ;

  input [FCLIP_INT_WD+FCLIP_FRC_WD-1 :0] cfg_fclip_i ; // <4,4>
  input vld_i ;

  output reg [UCLIP_WD -1:0] cfg_uclip_o ; // <7,0>

  output wr_buff_en_o ;
  output reg [1 :0] wr_buff_num_o ;

  output rd_buff_en_o ;
  output reg [1 :0] rd_buff_num_o ;

  output wr_hist_en_o ;
  output reg [1:0]wr_hist_num_o ;
  output [TILE_X_NUM -1:0] wr_hist_addr_o ;
  
  output reg rd_hist_en_a_o ;
  output reg [1:0]rd_hist_num_a_o ;
  output reg rd_hist_double_flg_a_o ;
  output reg [TILE_X_NUM -1:0] rd_hist_addr_a_o ;

  output reg rd_hist_en_b_o ;
  output reg [1:0] rd_hist_num_b_o ;
  output rd_hist_double_flg_b_o ;
  output [TILE_X_NUM -1:0] rd_hist_addr_b_o ;

  output cl_hist_en_c_o ;
  output reg [1:0] cl_hist_num_c_o ;

  output reg [`LOG2(`TILE_SIZ) -1:0]pos_x_lft_o ;
  output reg [`LOG2(`TILE_SIZ) -1:0]pos_y_up_o ;
  // wire/reg
  wire [UCLIP_TMP_INT_WD+FCLIP_FRC_WD -1:0] uclip_tmp_w ;

  reg vld_d0_r ;


  reg [`LOG2(`SIZ_FRA_X)-1:0] cnt_x_i_r ;
  wire cnt_x_i_done_w ;


  reg  [`LOG2(`TILE_SIZ)-1 -1:0] cnt_y_hf_tile_i_r ;
  wire cnt_y_hf_tile_i_done_w ;
  reg  [1-1:0] cnt_y_tile_i_r ;
  wire cnt_y_tile_i_done_w ;
  reg  [`LOG2(`SIZ_FRA_Y)-`LOG2(`TILE_SIZ) -1:0] cnt_y_i_r ;
  wire cnt_y_i_done_w ;

  reg vld_o_r ;

  reg  [`LOG2(`TILE_SIZ)-1 -1:0] cnt_x_hf_tile_o_r ;
  wire cnt_x_hf_tile_o_done_w ;
  reg  [1-1:0] cnt_x_tile_o_r ;
  wire cnt_x_tile_o_done_w ;
  reg [`LOG2(`SIZ_FRA_X)-`LOG2(`TILE_SIZ)-1:0] cnt_x_o_r ;
  wire cnt_x_o_done_w ;


  reg  [`LOG2(`TILE_SIZ)-1 -1:0] cnt_y_hf_tile_o_r ;
  wire cnt_y_hf_tile_o_done_w ;
  reg  [1-1:0] cnt_y_tile_o_r ;
  wire cnt_y_tile_o_done_w ;
  reg  [`LOG2(`SIZ_FRA_Y)-`LOG2(`TILE_SIZ) -1:0] cnt_y_o_r ;
  wire cnt_y_o_done_w ;

  // uclip_tmp_w
  assign uclip_tmp_w = cfg_fclip_i * `TILE_SIZ * `TILE_SIZ / (`GRAY_LEVEAL - 'd1) ;
  // cfg_uclip_o
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cfg_uclip_o <= 'd0 ;
    end
    else begin
      cfg_uclip_o <= uclip_tmp_w >> FCLIP_FRC_WD ;
    end
  end
  // vld_d0_r
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      vld_d0_r <= 'd0 ;
    end
    else begin
      vld_d0_r <= vld_i ;
    end
  end

  // cnt_x_i_r
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_x_i_r <= 'd0 ;
    end
    else begin
      if( vld_d0_r ) begin
        if( cnt_x_i_done_w ) begin
          cnt_x_i_r <= 'd0 ;
        end
        else begin
          cnt_x_i_r <= cnt_x_i_r + 'd1 ;
        end
      end
    end
  end
  assign cnt_x_i_done_w = cnt_x_i_r == `SIZ_FRA_X - 'd1 ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_y_hf_tile_i_r <= 'd0 ;
    end
    else begin
      if( vld_d0_r && cnt_x_i_done_w) begin
        if( cnt_y_hf_tile_i_done_w ) begin
          cnt_y_hf_tile_i_r <= 'd0 ;
        end
        else begin
          cnt_y_hf_tile_i_r <= cnt_y_hf_tile_i_r + 'd1 ;
        end
      end
    end
  end
  assign cnt_y_hf_tile_i_done_w = cnt_y_hf_tile_i_r == `TILE_SIZ/2 -'d1 ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_y_tile_i_r <= 'd0 ;
    end
    else begin
      if( vld_d0_r && cnt_x_i_done_w && cnt_y_hf_tile_i_done_w ) begin
        cnt_y_tile_i_r <= 'd0 ;
      end
      else begin
        cnt_y_tile_i_r <= cnt_y_tile_i_r + 'd1 ;
      end
    end
  end
  assign cnt_y_tile_i_done_w = cnt_y_tile_i_r == 'd2 - 'd1 ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_y_i_r <= 'd0 ;
    end
    else begin
      if( vld_d0_r && cnt_x_i_done_w && cnt_y_hf_tile_i_done_w && cnt_y_tile_i_done_w ) begin
        cnt_y_i_r <= 'd0 ;
      end
      else begin
        cnt_y_i_r <= cnt_y_i_r + 'd1 ;
      end
    end
  end
  assign cnt_y_i_done_w = cnt_y_i_r == TILE_Y_NUM - 'd1;
  // wr_buff_en_o
  assign wr_buff_en_o = vld_d0_r ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      wr_buff_num_o <= 'd0 ;
    end
    else begin
      if(  vld_d0_r 
        && cnt_x_i_done_w 
        && cnt_y_hf_tile_i_done_w
        ) begin
          if( wr_buff_num_o == 'd3 - 'd1 ) begin
            wr_buff_num_o <= 'd0 ;
          end
          else begin
            wr_buff_num_o <= wr_buff_num_o + 'd1 ;
          end
      end
    end
  end
  // vld_o_r
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      vld_o_r <= 'd0 ;
    end
    else begin
      if( vld_d0_r 
        && cnt_x_i_done_w
        && cnt_y_hf_tile_i_done_w
        && ~cnt_y_tile_i_done_w 
        &&(cnt_y_i_r == 'd1)
      ) begin
        vld_o_r <= 'd1 ;
      end
      else if( vld_o_r 
        && cnt_x_hf_tile_o_done_w 
        && cnt_x_tile_o_done_w 
        && cnt_x_o_done_w
        && cnt_y_hf_tile_o_done_w
        && cnt_y_tile_o_done_w 
        && cnt_y_o_done_w
      )begin
        vld_o_r <= 'd0 ;
      end
    end
  end
  // cnt_x_o_r
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_x_hf_tile_o_r <= 'd0 ;
    end
    else begin
      if( vld_o_r ) begin
        if( cnt_x_hf_tile_o_done_w ) begin
          cnt_x_hf_tile_o_r <= 'd0 ;
        end
        else begin
          cnt_x_hf_tile_o_r <= cnt_x_hf_tile_o_r + 'd1 ;
        end
      end
    end
  end
  assign cnt_x_hf_tile_o_done_w = cnt_x_hf_tile_o_r == `TILE_SIZ/2 -'d1 ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_x_tile_o_r <= 'd0 ;
    end
    else begin
      if( vld_o_r && cnt_x_o_done_w && cnt_x_hf_tile_o_done_w ) begin
        if( cnt_x_tile_o_done_w ) begin
          cnt_x_tile_o_r <= 'd0 ;
        end
        else begin
          cnt_x_tile_o_r <= cnt_x_tile_o_r + 'd1 ;
        end
      end
    end
  end
  assign cnt_x_tile_o_done_w = cnt_x_tile_o_r == 'd2 - 'd1 ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_x_o_r <= 'd0 ;
    end
    else begin
      if( vld_o_r && cnt_x_hf_tile_o_done_w && cnt_x_tile_o_done_w ) begin
        if( cnt_x_o_done_w ) begin
          cnt_x_o_r <= 'd0 ;
        end
        else begin
          cnt_x_o_r <= cnt_x_o_r + 'd1 ;
        end
      end
    end
  end
  assign cnt_x_o_done_w = cnt_x_o_r == TILE_X_NUM - 'd1;
  // cnt_y_hf_tile_o_r
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_y_hf_tile_o_r <= 'd0 ;
    end
    else begin
      if( vld_o_r
      && cnt_x_hf_tile_o_done_w 
      && cnt_x_tile_o_done_w 
      && cnt_x_o_done_w
      )begin
        if( cnt_y_hf_tile_o_done_w ) begin
          cnt_y_hf_tile_o_r <= 'd0 ;
        end
        else begin
          cnt_y_hf_tile_o_r <= cnt_y_hf_tile_o_r + 'd1 ;
        end
      end
    end
  end
  assign cnt_y_hf_tile_o_done_w = cnt_y_hf_tile_o_r == `TILE_SIZ/2 -'d1 ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_y_tile_o_r <= 'd0 ;
    end
    else begin
      if( vld_o_r 
      && cnt_x_hf_tile_o_done_w 
      && cnt_x_tile_o_done_w 
      && cnt_x_o_done_w 
      && cnt_y_hf_tile_o_done_w 
      ) begin
        if( cnt_y_tile_o_done_w ) begin
          cnt_y_tile_o_r <= 'd0 ;
        end
        else begin
          cnt_y_tile_o_r <= cnt_y_tile_o_r + 'd1 ;
        end
      end
    end
  end
  assign cnt_y_tile_o_done_w = cnt_y_tile_o_r == 'd2 - 'd1 ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      cnt_y_o_r <= 'd0 ;
    end
    else begin
      if( vld_o_r 
      && cnt_x_hf_tile_o_done_w 
      && cnt_x_tile_o_done_w 
      && cnt_x_o_done_w 
      && cnt_y_hf_tile_o_done_w 
      && cnt_y_tile_o_done_w 
      ) begin
        if( cnt_y_o_done_w ) begin
          cnt_y_o_r <= 'd0 ;
        end
        else begin
          cnt_y_o_r <= cnt_y_o_r + 'd1 ;
        end
      end
    end
  end
  assign cnt_y_o_done_w = cnt_y_o_r == TILE_Y_NUM - 'd1;
  // rd_buff_en_o
  assign rd_buff_en_o = vld_o_r ;
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_buff_num_o <= 'd0 ;
    end
    else begin
      if(  vld_o_r 
        && cnt_x_o_done_w 
        && cnt_y_hf_tile_o_done_w
        && ( rd_buff_num_o == 'd3 - 'd1 )
        ) begin
        rd_buff_num_o <= 'd0 ;
      end
      else begin
        rd_buff_num_o <= rd_buff_num_o + 'd1 ;
      end
    end
  end
  // wr_hist_en_o
  assign wr_hist_en_o = vld_d0_r ;
  always @( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      wr_hist_num_o <= 'd0 ;
    end
    else begin
      if( vld_d0_r
        &&cnt_x_i_done_w
        &&cnt_y_hf_tile_i_done_w 
        &&cnt_y_tile_i_done_w
      )begin
        if( wr_hist_num_o == 'd3 - 'd1 ) begin
          wr_hist_num_o <= 'd0 ;
        end
        else begin
          wr_hist_num_o <= wr_hist_num_o + 'd1 ;
        end
      end
    end
  end
  // wr_hist_addr_o
  assign wr_hist_addr_o = cnt_x_i_r[`LOG2(`SIZ_FRA_X)-1:`LOG2(`TILE_SIZ)] ;

  // rd_hist_en_a_o
  always@(*)begin
      rd_hist_en_a_o = 'd0 ;
    if( vld_o_r ) begin
      if( cnt_y_o_done_w && cnt_y_tile_o_done_w ) begin
        rd_hist_en_a_o = 'd0 ;
      end
      else begin
        rd_hist_en_a_o = 'd1 ;
      end
    end
    else begin
      rd_hist_en_a_o = 'd0 ;
    end
  end
  // rd_hist_double_flg_a_o
  always@(*) begin
    rd_hist_double_flg_a_o = 'd0 ;
    if( ( cnt_x_o_r >= `TILE_SIZ/2 ) 
     && ( cnt_x_o_r < `SIZ_FRA_X - `TILE_SIZ/2 )
     )begin
      rd_hist_double_flg_a_o = 'd1 ;
     end
     else begin
      rd_hist_double_flg_a_o = 'd0 ;
     end
  end
  // rd_hist_addr_a_o
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_hist_addr_a_o <= 'd0 ;
    end
    else begin
      if( vld_o_r 
      &&(cnt_x_o_r > `TILE_SIZ)
      &&(cnt_x_o_r < `SIZ_FRA_X - `TILE_SIZ)
      && cnt_x_hf_tile_o_done_w
      && ~cnt_x_tile_o_done_w
      ) begin
        rd_hist_addr_a_o <= rd_hist_addr_a_o + 'd1 ;
      end
      else if(
        vld_o_r
      && cnt_x_hf_tile_o_done_w 
      && cnt_x_tile_o_done_w 
      && cnt_x_o_done_w 
      )begin
        rd_hist_addr_a_o <= 'd0 ;
      end
    end
  end
  // rd_hist_num_a_o
  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      rd_hist_num_a_o <= 'd0 ;
    end
    else begin
      if( vld_o_r 
        && cnt_x_hf_tile_o_done_w
        && cnt_x_tile_o_done_w
        && cnt_x_o_done_w
        && (cnt_y_o_r > `TILE_SIZ)
        && (cnt_y_o_r < `SIZ_FRA_Y - `TILE_SIZ)
        && ~cnt_y_hf_tile_o_done_w
        && cnt_y_tile_o_done_w
      ) begin
        if( rd_hist_num_a_o == 'd3 - 'd1 ) begin
          rd_hist_num_a_o = 'd0 ;
        end
        else begin
          rd_hist_num_a_o <= rd_hist_num_a_o + 'd1 ;
        end
      end
      else if(
          vld_o_r
        && cnt_x_hf_tile_o_done_w
        &&cnt_x_tile_o_done_w
        &&cnt_x_o_done_w
        &&cnt_y_hf_tile_o_done_w
        &&cnt_y_tile_o_done_w
        &&cnt_y_o_done_w
      )begin
        rd_hist_num_a_o <= 'd0 ;
      end
    end
  end

  // rd_hist_en_b_o
  always@(*)begin
      rd_hist_en_b_o = 'd0 ;
    if( vld_o_r ) begin
      if( cnt_y_o_r == 'd0 && ~cnt_y_tile_o_done_w ) begin
        rd_hist_en_b_o = 'd0 ;
      end
      else begin
        rd_hist_en_b_o = 'd1 ;
      end
    end
    else begin
      rd_hist_en_b_o = 'd0 ;
    end
  end
  always@(*) begin
    rd_hist_num_b_o = 'd0 ;
    if( rd_hist_num_a_o == 'd3 - 'd1 ) begin
      rd_hist_num_b_o = 'd0 ;
    end
    else begin
      rd_hist_num_b_o = rd_hist_num_a_o + 'd1 ;
    end
  end
  assign rd_hist_addr_b_o = rd_hist_addr_a_o ;
  assign rd_hist_double_flg_b_o = rd_hist_double_flg_a_o ;

  always@(*) begin
    cl_hist_num_c_o = 'd0 ;
    if( rd_hist_num_b_o == 'd3 - 'd1 ) begin
      cl_hist_num_c_o = 'd0 ;
    end
    else begin
      cl_hist_num_c_o = rd_hist_num_b_o + 'd1 ;
    end
  end
  assign cl_hist_en_c_o = rd_hist_en_a_o
                        && (cnt_x_hf_tile_o_r == 'd0 ) 
                        && ( cnt_x_tile_o_r == 'd0 )
                        && (cnt_x_o_r == 'd0)
                        && (cnt_y_hf_tile_o_r  == 'd0 )
                        && ( cnt_y_tile_o_r == 'd0) 
  ;
  always@(*) begin
    pos_x_lft_o = 'd0 ;
    if( cnt_x_tile_o_done_w ) begin
      pos_x_lft_o = cnt_x_hf_tile_o_r ;
    end
    else begin
      pos_x_lft_o = cnt_x_hf_tile_o_r + `TILE_SIZ >> 1 ;
    end
  end
  always @(*) begin
    pos_y_up_o = 'd0 ;
    if( cnt_y_tile_o_done_w ) begin
      pos_y_up_o = cnt_y_hf_tile_o_r ;
    end
    else begin
      pos_y_up_o = cnt_y_hf_tile_o_r + `TILE_SIZ >> 1 ;
    end
  end

endmodule