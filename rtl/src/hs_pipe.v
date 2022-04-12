module hs_pipe #
(
	parameter DATA_WIDTH=256,
	parameter PIPE_DEPTH=8 ,
  parameter KONG_REG = 0
)
(
    input clk,
    input rst_n,
    
    input data_in_vld,
    input [DATA_WIDTH-1:0]data_in,
    output data_in_rdy,
    
    output  data_out_vld,
    output  [DATA_WIDTH-1:0]  data_out,
    input data_out_rdy
);

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
  bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction

localparam clog2_PIPE_DEPTH=clogb2(PIPE_DEPTH-1);

wire data_out_vld_w ;
reg [DATA_WIDTH-1:0]mem[PIPE_DEPTH-1:0];
reg [clog2_PIPE_DEPTH-1:0]w_pointer;reg w_phase;
reg [clog2_PIPE_DEPTH-1:0]r_pointer;reg r_phase;

wire wr_en=data_in_vld&data_in_rdy;
wire rd_en=data_out_vld_w&data_out_rdy;

always @(posedge clk or negedge rst_n)
if(~rst_n)
begin
	w_phase<=1'b0;
    w_pointer<=0;
end  
else
    if(wr_en)
    begin
        if( w_pointer == PIPE_DEPTH-1)
        begin
            w_pointer<='d0;
            w_phase <= ~w_phase;
        end
        else
            w_pointer<=w_pointer+'d1;
    end
    
always @(posedge clk or negedge rst_n)
if(~rst_n)
begin
    r_pointer<=0;
    r_phase<=1'b0;
end
else
    if(rd_en)
    begin
        if( r_pointer == PIPE_DEPTH-1)
        begin
            r_pointer<='d0;
        		r_phase<=~r_phase;    
        end
        else
            r_pointer<=r_pointer+'d1;
    end
    
always @(posedge clk)
if(wr_en)
    mem[w_pointer]<=data_in;
    
wire [DATA_WIDTH-1:0]data_out_c=mem[r_pointer];


wire empty=(w_pointer==r_pointer)&&(w_phase^~r_phase);
wire full=(w_pointer==r_pointer)&&(w_phase^r_phase);
assign data_out_vld_w=~empty;
assign data_in_rdy=~full;

generate
  if( KONG_REG == 1 ) begin : hasReg
    reg data_out_r ; 
    reg data_vld_r ;
    always@( posedge clk ) begin
      if( rd_en ) begin
        data_out_r <= mem[r_pointer];
      end
    end
    always @( posedge clk or negedge rst_n ) begin
      if( !rst_n ) begin
        data_vld_r <= 'd0 ;
      end
      else begin
        data_vld_r <= data_out_vld_w ;
      end
    end
    assign data_out = data_out_r ;
    assign data_out_vld = data_vld_r ;
  end
  else begin : noReg
    assign data_out = mem[r_pointer] ;
    assign data_out_vld = data_out_vld_w ;
  end
endgenerate

endmodule
