`include "../include.vh"
module che_cdf_map_knl(
  clk ,
  rstn ,

  vld_i ,
  hist_i ,
  dat_i ,

  vld_o ,
  dat_o
);
  input clk ;
  input rstn ;
  input vld_i ;
  input [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] hist_i ;
  input [`DAT_PIX_WD-1 -1:0] dat_i ;
  input vld_o ;
  output [`DAT_PIX_WD -1:0] dat_o ;

  wire [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] hist_w ;

  wire cdf_vld_l0_w ;
  wire cdf_vld_l1_w ;
  wire cdf_vld_l2_w ;
  wire cdf_vld_l3_w ;
  wire cdf_vld_l4_w ;
  wire cdf_vld_l5_w ;
  wire cdf_vld_l6_w ;
  wire cdf_vld_l7_w ;

  wire [(`HIST_BIN_WD    )*128 -1:0] cdf_sum_l0_w ;
  wire [(`HIST_BIN_WD+'d1)*64  -1:0] cdf_sum_l1_w ;
  wire [(`HIST_BIN_WD+'d2)*32  -1:0] cdf_sum_l2_w ;
  wire [(`HIST_BIN_WD+'d3)*16  -1:0] cdf_sum_l3_w ;
  wire [(`HIST_BIN_WD+'d4)*8   -1:0] cdf_sum_l4_w ;
  wire [(`HIST_BIN_WD+'d5)*4   -1:0] cdf_sum_l5_w ;
  wire [(`HIST_BIN_WD+'d6)*2   -1:0] cdf_sum_l6_w ;
  wire [(`HIST_BIN_WD+'d7)*1   -1:0] cdf_sum_l7_w ;

  reg vld_r ;
  reg [`DAT_PIX_WD -1:0] dat_r ;

  genvar gvIdx ;
  generate
    for( gvIdx=0; gvIdx<`GRAY_LEVEAL; gvIdx=gvIdx+1) begin : histLitter
      assign hist_w[(`HIST_BIN_WD*gvIdx)-1 :`HIST_BIN_WD] = (dat_i >= gvIdx) ? hist_i[(`HIST_BIN_WD*gvIdx)-1 :`HIST_BIN_WD] : 'd0 ; 
    end
  endgenerate

  assign cdf_sum_l0_w = hist_w ;

  che_cdf_adder #(
    .DAT_IN_WD ( `HIST_BIN_WD ),
    .DAT_IN_NUM(  'd128       ),
    .KONG_REG  (   'd0        )
  )che_cdf_adder_u0(
    .clk (clk),
    .rstn(rstn),

    .vld_i( cdf_vld_l0_w ),
    .dat_i( cdf_sum_l0_w ),

    .vld_o( cdf_vld_l1_w ),
    .sum_o( cdf_sum_l1_w )
  );
  che_cdf_adder #(
    .DAT_IN_WD ( `HIST_BIN_WD+'d1 ),
    .DAT_IN_NUM(  'd64       ),
    .KONG_REG  (   'd1        )
  )che_cdf_adder_u1(
    .clk (clk),
    .rstn(rstn),

    .vld_i( cdf_vld_l1_w ),
    .dat_i( cdf_sum_l1_w ),

    .vld_o( cdf_vld_l2_w ),
    .sum_o( cdf_sum_l2_w )
  );
  che_cdf_adder #(
    .DAT_IN_WD ( `HIST_BIN_WD+'d2 ),
    .DAT_IN_NUM(  'd32        ),
    .KONG_REG  (  'd0         )
  )che_cdf_adder_u2(
    .clk (clk),
    .rstn(rstn),

    .vld_i( cdf_vld_l2_w ),
    .dat_i( cdf_sum_l2_w ),

    .vld_o( cdf_vld_l3_w ),
    .sum_o( cdf_sum_l3_w )
  );
  che_cdf_adder #(
    .DAT_IN_WD ( `HIST_BIN_WD+'d3 ),
    .DAT_IN_NUM(  'd16       ),
    .KONG_REG  (  'd0        )
  )che_cdf_adder_u3(
    .clk (clk),
    .rstn(rstn),

    .vld_i( cdf_vld_l3_w ),
    .dat_i( cdf_sum_l3_w ),

    .vld_o( cdf_vld_l4_w ),
    .sum_o( cdf_sum_l4_w )
  );
  che_cdf_adder #(
    .DAT_IN_WD ( `HIST_BIN_WD+'d4 ),
    .DAT_IN_NUM(  'd8       ),
    .KONG_REG  (  'd1        )
  )che_cdf_adder_u4(
    .clk (clk),
    .rstn(rstn),

    .vld_i( cdf_vld_l4_w ),
    .dat_i( cdf_sum_l4_w ),

    .vld_o( cdf_vld_l5_w ),
    .sum_o( cdf_sum_l5_w )
  );
  che_cdf_adder #(
    .DAT_IN_WD ( `HIST_BIN_WD+'d5 ),
    .DAT_IN_NUM(  'd4       ),
    .KONG_REG  (  'd0        )
  )che_cdf_adder_u5(
    .clk (clk),
    .rstn(rstn),

    .vld_i( cdf_vld_l5_w ),
    .dat_i( cdf_sum_l5_w ),

    .vld_o( cdf_vld_l6_w ),
    .sum_o( cdf_sum_l6_w )
  );
  che_cdf_adder #(
    .DAT_IN_WD ( `HIST_BIN_WD+'d6 ),
    .DAT_IN_NUM(  'd2       ),
    .KONG_REG  (  'd1        )
  )che_cdf_adder_u6(
    .clk (clk),
    .rstn(rstn),

    .vld_i( cdf_vld_l6_w ),
    .dat_i( cdf_sum_l6_w ),

    .vld_o( cdf_vld_l7_w ),
    .sum_o( cdf_sum_l7_w )
  );

  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      dat_r <= 'd0 ;
    end
    else begin
      if( cdf_vld_l7_w ) begin
        dat_r <= cdf_sum_l7_w * 'd2 * (`GRAY_LEVEAL-'d1) / (`TILE_SIZ*`TILE_SIZ) ;
      end
    end
  end
  always @( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      vld_r <= 'd0 ;
    end
    else begin
      vld_r <= cdf_sum_l7_w ;
    end
  end
  assign vld_o = vld_r ;
  assign dat_o = dat_r ;
endmodule