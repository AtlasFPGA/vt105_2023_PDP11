
--
-- Copyright (c) 2008-2021 Sytse van Slooten
--
-- Permission is hereby granted to any person obtaining a copy of these VHDL source files and
-- other language source files and associated documentation files ("the materials") to use
-- these materials solely for personal, non-commercial purposes.
-- You are also granted permission to make changes to the materials, on the condition that this
-- copyright notice is retained unchanged.
--
-- The materials are distributed in the hope that they will be useful, but WITHOUT ANY WARRANTY;
-- without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--

-- $Revision$

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity top is
   port(
     greenled : out std_logic_vector(7 downto 0);
      --redled : out std_logic_vector(9 downto 0);

     -- sseg3 : out std_logic_vector(6 downto 0);
    --  sseg2 : out std_logic_vector(6 downto 0);
     -- sseg1 : out std_logic_vector(6 downto 0);
     -- sseg0 : out std_logic_vector(6 downto 0);

   --   vgar : out std_logic_vector(3 downto 0);
   --   vgag : out std_logic_vector(3 downto 0);
   --   vgab : out std_logic_vector(3 downto 0);
   --   vgah : out std_logic;
   --   vgav : out std_logic;
	
			TMDS_D0_O	: out std_logic;
			TMDS_D0_N   : out std_logic := '0';
			TMDS_D1_O	: out std_logic;
			TMDS_D1_N   : out std_logic := '0';
			TMDS_D2_O	: out std_logic;
			TMDS_D2_N   : out std_logic := '0';
			TMDS_CLK_O	: out std_logic;
			TMDS_CLK_N	: out std_logic := '0';

      ps2k_c : in std_logic;
      ps2k_d : in std_logic;

      clkin12 : in std_logic;

  --    sw : in std_logic_vector(9 downto 0);
  
      sw : out std_logic;
      tx : out std_logic;
      rx : in std_logic;

		tx2 : out std_logic;
		rx2 : in std_logic;

      resetbtn : in std_logic
   );
end top;
--end entity;

architecture implementation of top is



--component vt is
--   port(
--      vga_hsync : out std_logic;                                     -- horizontal sync
--      vga_vsync : out std_logic;                                     -- vertical sync
--      vga_fb : out std_logic;                                        -- output - full
--      vga_ht : out std_logic;                                        -- output - half
--      vga_den : out std_logic;                                        -- activar señal dibujo
---- serial port
--      tx : out std_logic;                                            -- transmit
--      rx : in std_logic;                                             -- receive
--      rts : out std_logic;                                           -- request to send
--      cts : in std_logic := '0';                                     -- clear to send
--      bps : in integer range 1200 to 230400 := 9600;                 -- bps rate - don't set to more than 38400
--      force7bit : in integer range 0 to 1 := 0;                      -- zero out high order bit on transmission and reception
--      rtscts : in integer range 0 to 1 := 0;                         -- conditional compilation switch for rts and cts signals; also implies to include core that implements a silo buffer
--
---- ps2 keyboard
--      ps2k_c : in std_logic;                                         -- clock
--      ps2k_d : in std_logic;                                         -- data
--
---- debug & blinkenlights
--      ifetch : out std_logic;                                        -- ifetch : the cpu is running an instruction fetch cycle
--      iwait : out std_logic;                                         -- iwait : the cpu is in wait state
--      teste : in std_logic := '0';                                   -- teste : display 24*80 capital E without changing the display buffer
--      testf : in std_logic := '0';                                   -- testf : display 24*80 all pixels on
--      vga_debug : out std_logic_vector(15 downto 0);                 -- debug output from microcode
--      vga_bl : out std_logic_vector(9 downto 0);                     -- blinkenlight vector
--
---- vt type code : 100 or 105
--      vttype : in integer range 100 to 105 := 100;                   -- vt100 or vt105
--      vga_cursor_block : in std_logic := '1';                        -- cursor is block ('1') or underline ('0')
--      vga_cursor_blink : in std_logic := '0';                        -- cursor blinks ('1') or not ('0')
--      have_act_seconds : in integer range 0 to 7200 := 900;          -- auto screen off time, in seconds; 0 means disabled
--      have_act : in integer range 1 to 2 := 2;                       -- auto screen off counter reset by keyboard and serial port activity (1) or keyboard only (2)
--
---- clock & reset
--      cpuclk : in std_logic;                                         -- cpuclk : should be around 10MHz, give or take a few
--      clk50mhz : in std_logic;                                       -- clk50mhz : used for vga signal timing
--      reset : in std_logic                                           -- reset
--   );
--end component;

component ssegdecoder is
   port(
      i : in std_logic_vector(3 downto 0);
      idle : in std_logic := '0';
      u : out std_logic_vector(6 downto 0)
   );
end component;

component mi_ppl is
   port(
      inclk0 : in std_logic := '0';
      c0 : out std_logic; -- 10mhz
		c1 : out std_logic; -- 50mhz
		c2 : out std_logic; -- 25mhz
		c3 : out std_logic  -- 125mhz
   );
end component;

component hdmi is
port (
	CLK_DVI_I	: in std_logic;
	CLK_PIXEL_I	: in std_logic;
	R_I		: in std_logic_vector(7 downto 0);
	G_I		: in std_logic_vector(7 downto 0);
	B_I		: in std_logic_vector(7 downto 0);
	BLANK_I		: in std_logic;
	HSYNC_I		: in std_logic;
	VSYNC_I		: in std_logic;
	TMDS_D0_O	: out std_logic;
	TMDS_D1_O	: out std_logic;
	TMDS_D2_O	: out std_logic;
	TMDS_CLK_O	: out std_logic);
end component;


component vt10x is
   port(
      vga_hsync : out std_logic;                                     -- horizontal sync
      vga_vsync : out std_logic;                                     -- vertical sync
      vga_fb : out std_logic;                                        -- output - full
      vga_ht : out std_logic;                                        -- output - half
      vga_den : out std_logic:= '0';                                       -- cuando esta activa la señal

-- serial port
      tx : out std_logic;                                            -- transmit
      rx : in std_logic;                                             -- receive
      rts : out std_logic;                                           -- request to send
      cts : in std_logic := '0';                                     -- clear to send
      bps : in integer range 1200 to 230400 := 9600;                 -- bps rate - don't set to more than 38400
      force7bit : in integer range 0 to 1 := 0;                      -- zero out high order bit on transmission and reception
      rtscts : in integer range 0 to 1 := 0;                         -- conditional compilation switch for rts and cts signals; also implies to include core that implements a silo buffer

-- ps2 keyboard
      ps2k_c : in std_logic;                                         -- clock
      ps2k_d : in std_logic;                                         -- data

-- debug & blinkenlights
      ifetch : out std_logic;                                        -- ifetch : the cpu is running an instruction fetch cycle
      iwait : out std_logic;                                         -- iwait : the cpu is in wait state
      teste : in std_logic := '0';                                   -- teste : display 24*80 capital E without changing the display buffer
      testf : in std_logic := '0';                                   -- testf : display 24*80 all pixels on
      vga_debug : out std_logic_vector(15 downto 0);                 -- debug output from microcode
      vga_bl : out std_logic_vector(9 downto 0);                     -- blinkenlight vector

-- vt type code : 100 or 105
      vttype : in integer range 100 to 105 := 100;                   -- vt100 or vt105
      vga_cursor_block : in std_logic := '1';                        -- cursor is block ('1') or underline ('0')
      vga_cursor_blink : in std_logic := '0';                        -- cursor blinks ('1') or not ('0')
      have_act_seconds : in integer range 0 to 7200 := 900;          -- auto screen off time, in seconds; 0 means disabled
      have_act : in integer range 1 to 2 := 2;                       -- auto screen off counter reset by keyboard and serial port activity (1) or keyboard only (2)

-- clock & reset
      cpuclk : in std_logic;                                         -- cpuclk : should be around 10MHz, give or take a few
      clk50mhz : in std_logic;                                       -- clk50mhz : used for vga signal timing
      reset : in std_logic                                           -- reset
   );
end component;




signal      vgar :  std_logic_vector(3 downto 0);
signal      vgag :  std_logic_vector(3 downto 0);
signal      vgab :  std_logic_vector(3 downto 0);
signal      vgah :  std_logic;
signal      vgav :  std_logic;


signal c0 : std_logic;
signal clkin : std_logic;
signal cpixel : std_logic;
signal chdmi : std_logic;


signal reset: std_logic;
signal vga_hsync : std_logic;
signal vga_vsync : std_logic;
signal vga_fb : std_logic;
signal vga_ht : std_logic;
signal   vga_den :  std_logic;


signal vga_debug : std_logic_vector(15 downto 0);

signal txtx : std_logic;
signal rxrx : std_logic;
signal swcyc1000  : std_logic;

begin
pll0: mi_ppl port map(
      inclk0 => clkin12,
      c0 => c0,
		c1 => clkin,
		c2 => cpixel,
		c3 => chdmi
   );
	
mi_hdmi: hdmi port map(
	CLK_DVI_I	=> chdmi,
	CLK_PIXEL_I	=> cpixel,
	R_I		=> vgar & vgar,
	G_I		=> vgag & vgag,
	B_I		=> vgab & vgab,
	BLANK_I		=>  vga_den,
	HSYNC_I		=>  vgah,
	VSYNC_I		=>  vgav,
	TMDS_D0_O	=>  TMDS_D0_O,
	TMDS_D1_O	=>  TMDS_D1_O,
	TMDS_D2_O	=>  TMDS_D2_O,
	TMDS_CLK_O	=>  TMDS_CLK_O);
	
	
	

--   c0 <= clkin;

   vt0: vt10x port map(
      vga_hsync => vga_hsync,
      vga_vsync => vga_vsync,
      vga_fb => vga_fb,
      vga_ht => vga_ht,
      vga_den => vga_den,
		
      rx => rxrx,
      tx => txtx,

      ps2k_c => ps2k_c,
      ps2k_d => ps2k_d,
		
 --     teste => swcyc1000,
 --	 teste => sw(0),
 --    testf => sw(1),
 --     vga_cursor_block => not sw(2),
 --     vga_cursor_blink => sw(3),
      vga_debug => vga_debug,
   --   vga_bl => redled,

      vttype => 105,

      cpuclk => c0,
      clk50mhz => clkin,
      reset => reset
   );

--   vt0: vt port map(
--      vga_hsync => vga_hsync,
--      vga_vsync => vga_vsync,
--      vga_fb => vga_fb,
--      vga_ht => vga_ht,
--      vga_den => vga_den,
		
--      rx => rxrx,
--      tx => txtx,

--      ps2k_c => ps2k_c,
--      ps2k_d => ps2k_d,
--      teste => sw(0),
--      testf => sw(1),
--      vga_cursor_block => not sw(2),
--      vga_cursor_blink => sw(3),
--      teste => '1',
--vga_cursor_blink =>'1',

  --    vga_debug => vga_debug,
 --     vga_bl => redled,

--      vttype => 105,

--      cpuclk => c0,
--      clk50mhz => clkin,
--      reset => reset
--   );

--   ssegd3: ssegdecoder port map(
--      i => vga_debug(15 downto 12),
--      u => sseg3
--   );
--   ssegd2: ssegdecoder port map(
--      i => vga_debug(11 downto 8),
--      u => sseg2
--   );
--   ssegd1: ssegdecoder port map(
--      i => vga_debug(7 downto 4),
--      u => sseg1
--   );
--   ssegd0: ssegdecoder port map(
--      i => vga_debug(3 downto 0),
--      u => sseg0
--   );

   reset <= (not resetbtn);

 --  tx <= txtx when sw(9) = '1' else '1';
 --  tx2 <= txtx when sw(9) = '0' else '1';
 --  rxrx <= rx when sw(9) = '1' else rx2;

 tx <= txtx;
 rxrx <= rx;
 
 
   vgag <= "1111" when vga_fb = '1' else "1000" when vga_ht = '1' else "0000";
   vgab <= "0000";
   vgar <= "0000";
   vgav <= vga_vsync;
   vgah <= vga_hsync;


end implementation;

