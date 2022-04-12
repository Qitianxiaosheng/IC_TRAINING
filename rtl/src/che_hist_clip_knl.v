`include "../include.vh"
module che_hist_clip_knl (
  clk ,
  rstn ,

  vld_i ,
  express_bin_i ,
  hist_i ,

  vld_o ,
  hist_o
);
input clk ;
input rstn ;
input vld_i ;
input [11 :0]express_bin_i ;
input [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] hist_i ;

output reg vld_o ;
output reg [(`GRAY_LEVEAL*`HIST_BIN_WD)-1 :0] hist_o ;

genvar gvIdx ;

wire [11-`LOG2(`GRAY_LEVEAL) -1:0] bin_incr ;

assign bin_incr = express_bin_i >> `LOG2(`GRAY_LEVEAL);
always @( posedge clk or negedge rstn ) begin
  if( !rstn ) begin
    vld_o <= 'd0 ;
  end
  else begin
    vld_o <= vld_i ;
  end
end

generate
  for( gvIdx=0; gvIdx<`GRAY_LEVEAL; gvIdx=gvIdx+1 ) begin : histClip
    always@( posedge clk or negedge rstn ) begin
      if( !rstn ) begin
        hist_o[`HIST_BIN_WD*gvIdx-1 -:`HIST_BIN_WD] <= 'd0 ;
      end
      else begin
        if( vld_i ) begin
          hist_o[`HIST_BIN_WD*gvIdx-1 -:`HIST_BIN_WD] <= hist_i[`HIST_BIN_WD*gvIdx-1 -:`HIST_BIN_WD] + bin_incr ;
        end
      end
    end
  end
endgenerate


endmodule