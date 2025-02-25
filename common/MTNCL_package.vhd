library ieee;
package MTNCL_gates is
	use ieee.std_logic_1164.all;
	use work.ncl_signals.all;
	component bufm_a is
		port(a : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component invm_a is
		port(a : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th12m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th12dm_a is
		port(a   : in  std_logic;
			 b   : in  std_logic;
			 rst : in  std_logic;
			 s   : in  std_logic;
			 z   : out std_logic);
	end component;
	component th12nm_a is
		port(a   : in  std_logic;
			 b   : in  std_logic;
			 rst : in  std_logic;
			 s   : in  std_logic;
			 z   : out std_logic);
	end component;
	component th13m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th14m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th22m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th23m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th23w2m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th24m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th24w22m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th24w2m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th24compm_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th33m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th34w2m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th34w22m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th34w32m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th34w3m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th34m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th44m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th44w22m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th44w322m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th44w2m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th44w3m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th54w22m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th54w322m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component th54w32m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component thand0m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
	component thxor0m_a is
		port(a : in  std_logic;
			 b : in  std_logic;
			 c : in  std_logic;
			 d : in  std_logic;
			 s : in  std_logic;
			 z : out std_logic);
	end component;
end MTNCL_gates;