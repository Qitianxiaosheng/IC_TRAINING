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
  input clk ;
  input rstn ;
  input [7 :0]cfg_fclip_i ; // <8,4>
  input vld_i ;
  input [7 :0] dat_i ;

  output vld_o ;
  output [7 :0] dat_o ;

  




endmodule