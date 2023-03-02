# vt105_2023_PDP11
se añaden los ficheros modificados en la creación de la terminal

En el fichero VGA se genera la señal vga_den que es la vga_blank,
que necesita el envoltorio hdmi, donde le indica donde esta activa la pantalla o no.

Para eso se modifica la señal vga:

--
-- temporización señal vga_den o blank_n
--
 | codigo agregado a vga.vhd |
 | :---          |
 | if ( vga_col >= 144 ) and |
   |  ( vga_col <  784 ) and |
   |  ( vga_row >=  36 ) and |
   |  ( vga_row <  516 ) then |
   |  ( vga_row <  514 ) then |
   | vga_den <= '0'; else |
   | vga_den <= '1'; end if; |
    
 luego esta señal tiene que viajar al modulo vt ,
 que en la ultima versión se llama vt10x internamente.
 
 Por último la señal vga_den se aplica en el envoltorio DVI. 
 
 
  | señal BLANK_I en TOP.vhd |
   | :--- |
 | mi_hdmi: hdmi port map( |
|	CLK_DVI_I	=> chdmi, |
|	CLK_PIXEL_I	=> cpixel, |
|	R_I		=> vgar & vgar, |
|	G_I		=> vgag & vgag, |
|	B_I		=> vgab & vgab, |
|	BLANK_I		=>  vga_den, |
|	HSYNC_I		=>  vgah, |
|	VSYNC_I		=>  vgav, |
|	TMDS_D0_O	=>  TMDS_D0_O, |
	TMDS_D1_O	=>  TMDS_D1_O,
	TMDS_D2_O	=>  TMDS_D2_O,
	TMDS_CLK_O	=>  TMDS_CLK_O);
