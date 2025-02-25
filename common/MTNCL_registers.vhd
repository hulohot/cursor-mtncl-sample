----------------------------------------------------------
--Contains 
--regm - No reset register
--regdm - Reset high register
--regnm - Reset low register
--genregm - Generic sized no-reset register
--genregrstm - Generic sized resettable register
--ShiftRegMTNCL - Pattern delay shift register
--PipeReg - Register for Pipelineing
----------------------------------------------------------

----------------------------------------------------------- 
-- regm
----------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use work.ncl_signals.all;
use work.MTNCL_gates.all;

entity regm is
	port(a     : in  dual_rail_logic;
		 sleep : in  std_logic;
		 z     : out dual_rail_logic);
end regm;

architecture arch of regm is

	signal t0, t1 : std_logic;
begin
	Gr0 : th12m_a
		port map(a.rail0, t0, sleep, t0);
	Gr1 : th12m_a
		port map(a.rail1, t1, sleep, t1);

	z.rail0 <= t0;
	z.rail1 <= t1;

end arch;

----------------------------------------------------------- 
-- regdm
----------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use work.ncl_signals.all;
use work.MTNCL_gates.all;

entity regdm is
	port(a     : in  dual_rail_logic;
		 rst   : in  std_logic;
		 sleep : in  std_logic;
		 z     : out dual_rail_logic);
end regdm;

architecture arch of regdm is

	signal t0, t1 : std_logic;
begin
	Gr0 : th12nm_a
		port map(a.rail0, t0, rst, sleep, t0);
	Gr1 : th12dm_a
		port map(a.rail1, t1, rst, sleep, t1);

	z.rail0 <= t0;
	z.rail1 <= t1;

end arch;

----------------------------------------------------------- 
-- regnm
----------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use work.ncl_signals.all;
use work.MTNCL_gates.all;
entity regnm is
	port(a     : in  dual_rail_logic;
		 rst   : in  std_logic;
		 sleep : in  std_logic;
		 z     : out dual_rail_logic);
end regnm;

architecture arch of regnm is
	signal t0, t1 : std_logic;
begin
	Gr0 : th12dm_a
		port map(a.rail0, t0, rst, sleep, t0);
	Gr1 : th12nm_a
		port map(a.rail1, t1, rst, sleep, t1);

	z.rail0 <= t0;
	z.rail1 <= t1;

end arch;

----------------------------------------------------------- 
-- regnullm
----------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use work.ncl_signals.all;
use work.MTNCL_gates.all;
entity regnullm is
	port(a     : in  dual_rail_logic;
		 rst   : in  std_logic;
		 sleep : in  std_logic;
		 z     : out dual_rail_logic);
end regnullm;

architecture arch of regnullm is

	signal t0, t1 : std_logic;
begin
	Gr0 : th12nm_a
		port map(a.rail0, t0, rst, sleep, t0);
	Gr1 : th12nm_a
		port map(a.rail1, t1, rst, sleep, t1);

	z.rail0 <= t0;
	z.rail1 <= t1;

end arch;

-- Generic Sleep Register
library ieee;
use ieee.std_logic_1164.all;
use work.ncl_signals.all;

entity genregm is
	generic(width : in integer := 4);
	port(a     : IN  dual_rail_logic_vector(width - 1 downto 0);
		 sleep : in  std_logic;
		 z     : out dual_rail_logic_vector(width - 1 downto 0));
end genregm;

architecture arch of genregm is
	component regm is
		port(a     : in  dual_rail_logic;
			 sleep : in  std_logic;
			 z     : out dual_rail_logic);
	end component;

begin
	Greg : for i in 0 to width - 1 generate
	begin
		Gsr0 : regm
			port map(a(i), sleep, z(i));

	end generate;

end arch;

-- Pipelining Register
library ieee;
use ieee.std_logic_1164.all;
use work.ncl_signals.all;

entity PipeRegm is
	generic(width : in integer := 4);
	port(a     : IN  dual_rail_logic_vector(width - 1 downto 0);
		 ki, rst, sleep : in std_logic;
		 sleepout, ko : out  std_logic;
		 z     : out dual_rail_logic_vector(width - 1 downto 0));
end PipeRegm;

architecture arch of PipeRegm is
	component genregm is
	generic(width : in integer := 4);
	port(a     : IN  dual_rail_logic_vector(width - 1 downto 0);
		 sleep : in  std_logic;
		 z     : out dual_rail_logic_vector(width - 1 downto 0));
	end component;
	
	component compm is
		generic(width : in integer := 4);
		port(a              : IN  dual_rail_logic_vector(width - 1 downto 0);
			 ki, rst, sleep : in  std_logic;
			 ko             : OUT std_logic);
	end component;
	
	signal temp : dual_rail_logic_vector(width - 1 downto 0);
	signal k_Reg1, k_Reg2 : std_logic;

begin
	Reg1 : genregm
		generic map(width)
		port map(a, k_reg1, temp);
	Comp1 : compm
		generic map(width)
		port map(a, k_reg2, rst, sleep, k_reg1);
	
	Reg2 : genregm
		generic map(width)
		port map(temp, k_reg2, z);
	Comp2 : compm
		generic map(width)
		port map(temp, ki, rst, k_reg1, k_reg2);
		
	sleepout <= k_reg2;
	ko <= k_reg1;
		
end arch;

----------------------------------------------------------- 
-- genregrstm
----------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ncl_signals.all;
--use work.MTNCL_gates.all;

entity genregrstm is
	generic(width : in integer    := 4;
		    dn    : in bit        := '1';
		    value : in bit_vector := "0110");
	port(a     : IN  dual_rail_logic_vector(width - 1 downto 0);
		 rst   : in  std_logic;
		 sleep : in  std_logic;

		 z     : out dual_rail_logic_vector(width - 1 downto 0));
end genregrstm;

architecture arch of genregrstm is
	component regnm is
		port(a     : in  dual_rail_logic;
			 rst   : in  std_logic;
			 sleep : in  std_logic;
			 z     : out dual_rail_logic);
	end component;

	component regdm is
		port(a     : in  dual_rail_logic;
			 rst   : in  std_logic;
			 sleep : in  std_logic;
			 z     : out dual_rail_logic);
	end component;

	component regnullm is
		port(a     : in  dual_rail_logic;
			 rst   : in  std_logic;
			 sleep : in  std_logic;
			 z     : out dual_rail_logic);
	end component;

--signal  regval : unsigned (width-1 downto 0) := to_unsigned(value,width);
begin

	--convert value into std_logic
	-- regval <= (to_unsigned(value, width));
	Gwithreset : for i in 0 to width - 1 generate
		Gresetnull : if dn = '0' generate
			G1 : regnullm
				port map(a(i), rst, sleep, z(i));
		end generate;

		Gresetlow : if (dn = '1' and value(i) = '0') generate
			G2 : regnm
				port map(a(i), rst, sleep, z(i));
		end generate;
		Gresethigh : if (dn = '1' and value(i) = '1') generate
			G3 : regdm
				port map(a(i), rst, sleep, z(i));
		end generate;
	end generate;

end arch;

----------------------------------------------------^M
-- Definition of register in MTNCL with even stages
----------------------------------------------------^M

Library IEEE;
use IEEE.std_logic_1164.all;
use work.ncl_signals.all;
entity Eregm is
  generic(width: in integer := 8);
  port(x: in dual_rail_logic_vector(width-1 downto 0);
    ki, rst, sleep: in std_logic;
    y: out dual_rail_logic_vector(width-1 downto 0);
    sleepout: out std_logic;
    ko: out std_logic);
end;

architecture arch of Eregm is

  
    component regm is 
        port(a: in dual_rail_logic; 
         sleep:in std_logic;
             z: out dual_rail_logic ); 
    end component; 
  
    component compm is
     generic(width: in integer := 4);
     port(a: IN dual_rail_logic_vector(width-1 downto 0);
          ki, rst, sleep: in std_logic;
          ko: OUT std_logic);
  end component;

  
  signal regmid : dual_rail_logic_vector(width-1 downto 0);
  signal komid, kor: std_logic;

  begin

        
  Genreg0:    for i in 0 to width-1 generate  
   Gsreg0: regm 
    port map(x(i),  kor, regmid(i));

  end generate;
      
     Gencomp0: compm
       generic map(width)
       port map(x, komid, rst, sleep, kor);

  Genreg1:    for i in 0 to width-1 generate  
   Gsreg1: regm 
    port map(regmid(i), komid, y(i));

  end generate;
      
     Gencomp1: compm
       generic map(width)
       port map(regmid, ki, rst, kor, komid);

  ko <= kor;
  sleepout <= komid;
    
 end arch;

----------------------------------------------------------- 
--Pattern-delay shift-register in MTNCL
----------------------------------------------------------- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ncl_signals.all;
use work.MTNCL_gates.all;

entity ShiftRegMTNCL is
	generic(width : in integer    := 4;
		    value : in bit_vector := "0110");
	port(wrapin   : in  dual_rail_logic_vector(width - 1 downto 0);
		 ki       : in  std_logic;
		 rst      : in  std_logic;
		 sleep    : in  std_logic;
		 wrapout  : out dual_rail_logic_vector(width - 1 downto 0);
		 sleepout : out std_logic;
		 ko       : out std_logic);
end ShiftRegMTNCL;

architecture arch of ShiftRegMTNCL is
	component genregrstm is
		generic(width : in integer    := 4;
			    dn    : in bit        := '1';
			    value : in bit_vector := "0110");
		port(a     : IN  dual_rail_logic_vector(width - 1 downto 0);
			 rst   : in  std_logic;
			 sleep : in  std_logic;
			 z     : out dual_rail_logic_vector(width - 1 downto 0));
	end component;

	component compm is
		generic(width : in integer := 4);
		port(a              : IN  dual_rail_logic_vector(width - 1 downto 0);
			 ki, rst, sleep : in  std_logic;
			 ko             : OUT std_logic);
	end component;

	component compdm is
		generic(width : in integer := 4);
		port(a              : IN  dual_rail_logic_vector(width - 1 downto 0);
			 ki, rst, sleep : in  std_logic;
			 ko             : OUT std_logic);
	end component;
	
    component Eregm is
		generic(width: in integer := 8);
		port(x: in dual_rail_logic_vector(width-1 downto 0);
		ki, rst, sleep: in std_logic;
		y: out dual_rail_logic_vector(width-1 downto 0);
		sleepout: out std_logic;
		ko: out std_logic);
	end component;

	signal wrap, wrapbuf, r12 : dual_rail_logic_vector(width - 1 downto 0);
	signal wrapbuf_0		: dual_rail_logic_vector(width - 1 downto 0);
	signal c1, c2, kibuf    : std_logic;
	signal kibuf_1,	sleepout_0	: std_logic;

begin
	Gregdata : genregrstm
		generic map(width, '1', value)  ----reset to DATA
		port map(wrapin, rst, c1, r12);
	Gcompnull : compm                   -----reset to request for NULL
		generic map(width)
		port map(wrapin, c2, rst, sleep, c1);

	Gregnull : genregrstm
		generic map(width, '0', value)  --reset to NULL        
		port map(r12, rst, c2, wrap);
	Gcompdata : compdm
		generic map(width)
		port map(r12, kibuf, rst, c1, c2); --reset to requrest for DATA

	Gbuf: Eregm
		generic map(width)
		port map(wrap, kibuf_1, rst, c2, wrapbuf_0, sleepout_0, kibuf);
		
	Gbuf_1 : Eregm
		generic map(width)
		port map(wrapbuf_0, ki, rst, sleepout_0, wrapbuf, sleepout, kibuf_1);
		
	wrapout <= wrapbuf;
	ko       <= c1;

end arch;

