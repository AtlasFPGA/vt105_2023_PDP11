# vt105_2023_PDP11
se añaden los ficheros modificados en la creación de la terminal

En el fichero VGA se genera la señal vga_den que es la vga_blank_I,
Que es la señal que discrimina cuando esta activo o nó el rayo catódico
"si tener en cuenta que el paso a DVI primero se conforma una VGA",
Se necesita el envoltorio DVI, En este caso usamos un envoltorio muy simple
donde todas las selales de pares diferenciales se van a 0 lógico
y sólo va información por los pares positivos, donde le indica donde esta activa la pantalla o no.

Para eso se modifica la señal vga dentro del fichero vga.vhd
que esta en el directorio principal:



 temporización señal vga_den o blank_n

 | codigo agregado a vga.vhd |
 | :---          |
 | if ( vga_col >= 144 ) and |
   |  ( vga_col <  784 ) and |
   |  ( vga_row >=  36 ) and |
   |  ( vga_row <  516 ) then |
   |  ( vga_row <  514 ) then |
   | vga_den <= '0'; else |
   | vga_den <= '1'; end if; |
    
 luego esta señal tiene que viajar al modulo vt desde el modulo vga ,
 luego hay que definir vga_den y propagar dicha señal.
 que en la ultima versión se llama vt10x internamente.
 
 Por último estamos en la señal top de un vt105 la señal vga_den
 se aplica en el envoltorio DVI. 
 
 
  | señal BLANK_I en top.vhd |
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
|	TMDS_D1_O	=>  TMDS_D1_O, |
|	TMDS_D2_O	=>  TMDS_D2_O, |
|	TMDS_CLK_O	=>  TMDS_CLK_O); |

Esta es la pinta de como llamamos a un envoltorio DVI sin sonido.

También hay que mirar el uso del pll porque nos indica datos curiosos
sobre las señales DVI:


 Analicemos el pll que por equivocación llame ppl: 
   | Explicaciones pll |  aclaraciónes |
   | :--- |  :--- |
   |begin | llamada |
   |pll0: mi_ppl port map( | instancia pll0 |
   |    inclk0 => clkin12, | reloj de entrada cyc1000 12Mhz|
   |   c0 => c0, | 10Mhz|
   |c1 => clkin, | 50Mhz|
   |c2 => cpixel, | 25Mhz|
   |c3 => chdmi | 125Mhz |
   | ); |  |
   
   si nos fijamos en digital siempre se ajusta a 25Mhz
   cuando la frecuencia analógica de la resolución es 25,125Mhz.
   
   A un envorltorio DVI siempre va la frecuencia de la vga que estemos usando,
   y luego 5 veces más frecuencia para poder usar los serializadores y
   los pares diferenciales.
   
   En este caso sería 25Mhz -> Reloj de pixel
   En este caso sería 125Mhz -> Reloj serializadores envoltorio DVI. 
