`include "../include.vh"

module che_cdf_adder(
  clk ,
  rstn ,

  vld_i ,
  dat_i ,

  vld_o ,
  sum_o
);
  parameter DAT_IN_WD = -1 ;
  parameter DAT_IN_NUM = -1 ;
  parameter KONG_REG = -1 ;

  localparam DAT_OUT_NUM = DAT_IN_NUM / 'd2 ;
  localparam DAT_OUT_WD = DAT_IN_WD + 'd1 ;

  input clk ;
  input rstn ;
  input vld_i ;
  input [DAT_IN_WD*DAT_IN_NUM -1:0] dat_i ;

  wire [DAT_IN_WD*DAT_OUT_NUM -1:0] dat_a_w ;
  wire [DAT_IN_WD*DAT_OUT_NUM -1:0] dat_b_w ;

  output vld_o ;
  output [DAT_OUT_WD*DAT_OUT_NUM -1:0] sum_o ;

  wire [DAT_OUT_WD*DAT_OUT_NUM -1:0] sum_w ;

  assign dat_a_w = dat_i[DAT_IN_WD*(DAT_IN_NUM/2) -1:0] ;
  assign dat_b_w = dat_i[DAT_IN_WD*(DAT_IN_NUM)   -1:DAT_IN_WD*(DAT_IN_NUM/2)] ;
  genvar gvIdx ;
  generate
    for( gvIdx='d0; gvIdx<DAT_OUT_NUM; gvIdx=gvIdx+'d1 ) begin : sumUnit
      assign sum_w[DAT_OUT_WD*(DAT_OUT_NUM-gvIdx)-1 -:DAT_OUT_WD] 
          =  dat_a_w[DAT_IN_WD*(DAT_OUT_NUM-gvIdx)-1 -:DAT_IN_WD] + dat_b_w[DAT_IN_WD*(DAT_OUT_NUM-gvIdx)-1 -:DAT_IN_WD] ;
    end
  endgenerate

  generate
    if( KONG_REG == 'd0 ) begin : noReg
      assign sum_o = sum_w ;
      assign vld_o = vld_i ;
    end
    else if( KONG_REG == 'd1 )begin : hasReg
      reg [DAT_OUT_WD*DAT_OUT_NUM -1:0] sum_r ;
      reg val_r  ;
      always@( posedge clk or negedge rstn ) begin
        if( !rstn ) begin
          val_r <= 'd0 ;
          sum_r <= 'd0 ;
        end
        else begin
          val_r <= vld_i ;
          sum_r <= sum_w ;
        end
      end
      assign sum_o = sum_r ;
      assign vld_o = val_r ;
    end
  endgenerate

endmodule