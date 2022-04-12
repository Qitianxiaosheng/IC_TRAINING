`include "../include.vh"

module che_line_buffer(

  clk ,
  rstn ,

  wr_buff_en_i ,
  wr_buff_dat_i ,
  wr_buff_num_i ,

  rd_buff_en_i ,
  rd_buff_num_i ,

  vld_o ,
  dat_o
);
input clk ;
input rstn ;

input wr_buff_en_i ;
input [`DAT_PIX_WD-1 -1:0] wr_buff_dat_i ;
input [1:0] wr_buff_num_i ;

input rd_buff_en_i ;
input [1:0] rd_buff_num_i ;

output vld_o ;
output reg [`DAT_PIX_WD-1 -1:0] dat_o ;

reg rd_buff_en_d0_r ;
reg [1:0] rd_buff_num_d0_r ;
wire [`DAT_PIX_WD-1 -1:0] dat_w[2:0] ;
genvar gvIdx ;

always@( posedge clk or negedge rstn ) begin
  if( !rstn ) begin
    rd_buff_en_d0_r <= 'd0 ;
    rd_buff_num_d0_r <= 'd0 ;
  end
  else begin
    rd_buff_en_d0_r <= rd_buff_en_i ;
    rd_buff_num_d0_r <= rd_buff_num_i ;
  end
end

generate
  for(gvIdx=0;gvIdx<'d2;gvIdx=gvIdx+'d1) begin : lineBuff
    wire line_buff_vld_i_w ;
    wire [`DAT_PIX_WD-1 -1:0] line_buff_dat_i_w ;

    wire line_buff_rdy_i_w ;
    wire [`DAT_PIX_WD-1 -1:0] line_buff_dat_o_w ;

    assign line_buff_vld_i_w = wr_buff_en_i && ( wr_buff_num_i==gvIdx ) ;
    assign line_buff_dat_i_w = wr_buff_dat_i ;
    assign line_buff_rdy_i_w = rd_buff_en_i && ( rd_buff_num_i== gvIdx ) ;

    hs_pipe #(
      .DAT_WD(`DAT_PIX_WD-1),
      .DAT_DEPTH(`SIZ_FRA_X*`TILE_SIZ/2+'d10),
      .KONG_REG(1)
    )che_line_buffer_knl(
      .clk (clk) ,
      .rst_n (rstn) ,
      .data_in_vld( line_buff_vld_i_w ) ,
      .data_in_rdy(/* UN_SET*/) ,
      .data_in( line_buff_dat_i_w ) ,
      .data_out_vld(/* UN_SET*/) ,
      .data_out_rdy( line_buff_rdy_i_w ) ,
      .data_out( dat_w[gvIdx] )
    );
  end
endgenerate
//vld_o
assign vld_o = rd_buff_en_d0_r ;
// dat_o
always@(*) begin
  dat_o = 'd0 ;
  case( rd_buff_num_d0_r )
    'd0 : dat_o = dat_w[0] ;
    'd1 : dat_o = dat_w[1] ;
    'd2 : dat_o = dat_w[2] ;
  endcase
end
endmodule