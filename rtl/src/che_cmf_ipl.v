`include "../include.vh"
module che_cmf_ipl (
  clk ,
  rstn ,

  ul_vld_i ,
  ur_vld_i ,
  bl_vld_i ,
  br_vld_i ,

  pos_x_i ,
  pos_y_i ,

  ul_dat_i ,
  ur_dat_i ,
  bl_dat_i ,
  br_dat_i ,

  vld_o ,
  dat_o
);
  input clk ;
  input rstn ;

  input ul_vld_i ;
  input ur_vld_i ;
  input bl_vld_i ;
  input br_vld_i ;

  input [`LOG2(`TILE_SIZ)-1:0] pos_x_i ;
  input [`LOG2(`TILE_SIZ)-1:0] pos_y_i ;
  input [`DAT_PIX_WD-1 :0] ul_dat_i ;
  input [`DAT_PIX_WD-1 :0] ur_dat_i ;
  input [`DAT_PIX_WD-1 :0] bl_dat_i ;
  input [`DAT_PIX_WD-1 :0] br_dat_i ;

  output vld_o ;
  output[`DAT_PIX_WD-1 :0] dat_o ;

  reg up_vld_d0_r ;
  reg [`DAT_PIX_WD + `LOG2(`TILE_SIZ) -1:0] up_dat_d0_r ;
  reg bottom_vld_d0_r ;
  reg [`DAT_PIX_WD + `LOG2(`TILE_SIZ) -1:0] bottom_dat_d0_r ;

  reg vld_d1_r ;
  reg [`DAT_PIX_WD + 2*`LOG2(`TILE_SIZ) -1:0] dat_d1_r ;

  always @( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      up_vld_d0_r <= 'd0 ;
      up_dat_d0_r <= 'd0 ;
    end
    else begin
      up_vld_d0_r <= ul_vld_i || ur_vld_i ;
      if( ul_vld_i && ur_vld_i ) begin
        up_dat_d0_r <= (`TILE_SIZ-pos_x_i) * ul_dat_i + pos_x_i * ur_dat_i ;
      end
      else if( ul_vld_i ) begin
        up_dat_d0_r <= ul_dat_i << `LOG2(`TILE_SIZ) ;
      end
    end
  end

  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      bottom_vld_d0_r <= 'd0 ;
      bottom_dat_d0_r <= 'd0 ;
    end
    else begin
      bottom_vld_d0_r <= bl_vld_i || br_vld_i ;
      if( bl_vld_i && br_vld_i ) begin
        bottom_dat_d0_r <= (`TILE_SIZ-pos_x_i) * bl_dat_i + pos_x_i * br_dat_i ;
      end
      else if( bl_vld_i )begin
        bottom_dat_d0_r <= bl_dat_i << `LOG2(`TILE_SIZ) ;
      end
    end
  end

  always@( posedge clk or negedge rstn ) begin
    if( !rstn ) begin
      vld_d1_r <= 'd0 ;
      dat_d1_r <= 'd0 ;
    end
    else begin
      vld_d1_r <= up_vld_d0_r || bottom_vld_d0_r ;
      if( up_vld_d0_r && bottom_vld_d0_r ) begin
        dat_d1_r <= (`TILE_SIZ-pos_y_i) * up_dat_d0_r + pos_y_i * bottom_dat_d0_r ;
      end
      else if( up_vld_d0_r ) begin
        dat_d1_r <= up_dat_d0_r<<`LOG2(`TILE_SIZ) ;
      end
      else if( bottom_vld_d0_r ) begin
        dat_d1_r <= bottom_dat_d0_r<<`LOG2(`TILE_SIZ) ;
      end
    end
  end
  assign vld_o = vld_d1_r ;
  assign dat_o = dat_d1_r >> ( 2*`LOG2(`TILE_SIZ)) ;
endmodule