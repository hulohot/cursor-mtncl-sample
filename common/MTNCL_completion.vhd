---------
--Contains
--tree_funcs package
--andtreem - MTNCL generic and tree
--compm - MTNCL completion block, resets high
--compdm - MTNCL completion block, resets low
--comp1m - MTNCL completion block, one additional Ki signal, resets high
--comp1dm - MTNCL completion block, one additional Ki signal, resets low



-- Generic AND tree
library ieee;
use IEEE.std_logic_1164.all;

package tree_funcs is

function pow_u(B: integer; E: integer) return integer; -- B to the E
function div_u(D: integer; B: integer) return integer; -- celing of d/b
function log_u(L: integer; R: integer) return integer; -- ceiling of Log base R of L
function level_number(width, level, base: integer) return integer; -- bits to be combined on level of tree of width using base input gates

end tree_funcs;

package body tree_funcs is

function pow_u(B: integer; E: integer) return integer is
variable temp: integer := 1;
variable level: integer := 1;
begin
  if E = 0 then
      return 1;
  end if;
  if E = 1 then
      return B;
end if;
  temp := B;
while level < E loop
  temp := temp * B;
  level := level + 1;
end loop;
return temp;
end;


function div_u(D: integer; B: integer) return integer is
variable temp: integer := 1;
variable level: integer := 0;
begin
  if D = 0 then
      return 0;
  end if;
  temp := D rem B;
  level := D/B;
  if temp /= 0 then
      level := level + 1;
  end if;
    return level;
  
end;

function log_u(L: integer; R: integer) return integer is
variable temp: integer := 1;
variable level: integer := 0;
begin
        if L = 1 then
                return 0;
        end if;

        while temp < L loop
                temp := temp * R;
                level := level + 1;
        end loop;
        return level;
end;

function level_number(width, level, base: integer) return integer is
variable num: integer := width;
begin
    if level /= 0 then
  for i in 1 to level loop
    if (log_u((num / base) + (num rem base), base) + i) = log_u(width, base) then
      num := (num / base) + (num rem base);
    else
      num := (num / base) + 1;
    end if;
  end loop;
    end if;
    return num;
end;

end tree_funcs;

library ieee;
use ieee.std_logic_1164.all;
use work.tree_funcs.all;
use work.MTNCL_gates.all;

entity andtreem is
   generic(width: in integer := 4);
   port(a: IN std_logic_vector(width-1 downto 0);
        sleep: in std_logic;
        ko: OUT std_logic);
end andtreem;

architecture arch of andtreem is

  type completion is array(log_u(width, 4) downto 0, width-1 downto 0) of std_logic;
  signal comp_array: completion;
  

begin
  RENAME: for i in 0 to width-1 generate
    comp_array(0, i) <= a(i);
  end generate;

  STRUCTURE: for k in 0 to log_u(width, 4)-1 generate
  begin
     NOT_LAST: if level_number(width, k, 4) > 4 generate
     begin
    PRINCIPLE: for j in 0 to (level_number(width, k, 4) / 4)-1 generate
      G4: th44m_a
        port map(comp_array(k, j*4), comp_array(k, j*4+1), comp_array(k, j*4+2), comp_array(k, j*4+3),sleep, 
          comp_array(k+1, j));
    end generate;

    LEFT_OVER_GATE: if log_u((level_number(width, k, 4) / 4) + (level_number(width, k, 4) rem 4), 4) + k + 1 
          /= log_u(width, 4) generate
    begin
      NEED22: if (level_number(width, k, 4) rem 4) = 2 generate
            G2: th22m_a
                                  port map(comp_array(k, level_number(width, k, 4)-2), comp_array(k, level_number(width, k, 4)-1), sleep,
            comp_array(k+1, (level_number(width, k, 4) / 4)));
      end generate;

      NEED33: if (level_number(width, k, 4) rem 4) = 3 generate
                                G3: th33m_a
                                        port map(comp_array(k, level_number(width, k, 4)-3), comp_array(k, level_number(width, k, 4)-2), 
            comp_array(k, level_number(width, k, 4)-1), sleep, comp_array(k+1, (level_number(width, k, 4) / 4)));
                        end generate;
                end generate;

                LEFT_OVER_SIGNALS: if (log_u((level_number(width, k, 4) / 4) + (level_number(width, k, 4) rem 4), 4) + k + 1
                                        = log_u(width, 4)) and ((level_number(width, k, 4) rem 4) /= 0) generate
                begin
      RENAME_SIGNALS: for h in 0 to (level_number(width, k, 4) rem 4)-1 generate
        comp_array(k+1, (level_number(width, k, 4) / 4)+h) <= comp_array(k, level_number(width, k, 4)-1-h);
                        end generate;
                end generate;
     end generate;

     LAST22: if level_number(width, k, 4) = 2 generate
    G2F: th22m_a
                        port map(comp_array(k, 0), comp_array(k, 1), sleep, ko);
           end generate;

           LAST33: if level_number(width, k, 4) = 3 generate
                G3F: th33m_a
                        port map(comp_array(k, 0), comp_array(k, 1), comp_array(k, 2),sleep, ko);
           end generate;

           LAST44: if level_number(width, k, 4) = 4 generate
                G4F: th44m_a
                        port map(comp_array(k, 0), comp_array(k, 1), comp_array(k, 2), comp_array(k, 3), sleep, ko);
           end generate;
  end generate;

end arch;

-- Generic Completion (sleep)
library ieee;
use ieee.std_logic_1164.all;
use work.ncl_signals.all;
use work.MTNCL_gates.all;

entity compm is
  generic(width: in integer := 4);
   port(a: IN dual_rail_logic_vector(width-1 downto 0);
        ki, rst, sleep: in std_logic;
        ko: OUT std_logic);
end compm;

architecture arch of compm is


  
    component th22n_a is 
        port(a: in std_logic; 
             b: in std_logic;  
             rst: in std_logic;
       z: out std_logic ); 
    end component; 

	component INV_A is
	port(A : in  std_logic;
	 	Z : out std_logic);
	end component;
         
                component andtreem is
           generic(width: in integer := 4);
           port(a: IN std_logic_vector(width-1 downto 0);
                sleep: in std_logic;
                ko: OUT std_logic);
        end component;
        
        signal t : std_logic_vector(width/2 downto 0);
        signal tko, ttko: std_logic;
begin
  


  STAGE1: for i in 0 to width/2-1 generate
    Gs1: th24compm_a
      port map(a(i*2).rail0,a(i*2).rail1, a(i*2+1).rail0, a(i*2+1).rail1, sleep, t(i));
  end generate;
  ONEMORE: if width rem 2 = 1 generate
    Gsom: th12m_a
      port map(a(width-1).rail0, a(width-1).rail1, sleep, t(width/2));
  end generate;
  

  Gcompodd: if width rem 2 = 1 generate
  begin
    Gco: andtreem
      generic map(width/2+1)
      port map(t, sleep, tko);
    end generate;
    
  Gcompeven: if width rem 2 = 0 generate
  begin
  Gce: andtreem
    generic map(width/2)
    port map(t(width/2-1 downto 0), sleep, tko);
  end generate;
  
  
  Gfgate: th22n_a
    port map(tko, ki, rst, ttko);
  INV1: INV_A
  	port map(ttko, ko);




end arch;


-- Generic Completion (sleep)
library ieee;
use ieee.std_logic_1164.all;
use work.MTNCL_gates.all;
use work.ncl_signals.all;

entity compdm is
  generic(width: in integer := 4);
   port(a: IN dual_rail_logic_vector(width-1 downto 0);
        ki, rst, sleep: in std_logic;
        ko: OUT std_logic);
end compdm;

architecture arch of compdm is


  
    component th22d_a is 
        port(a: in std_logic; 
             b: in std_logic;  
             rst: in std_logic;
       z: out std_logic ); 
    end component;

	component INV_A is
	port(A : in  std_logic;
	 	Z : out std_logic);
	end component;
        
                component andtreem is
           generic(width: in integer := 4);
           port(a: IN std_logic_vector(width-1 downto 0);
                sleep: in std_logic;
                ko: OUT std_logic);
        end component;
        
        signal t : std_logic_vector(width/2 downto 0);
        signal tko, ttko: std_logic;
begin
  


  STAGE1: for i in 0 to width/2-1 generate
    Gs1: th24compm_a
      port map(a(i*2).rail0,a(i*2).rail1, a(i*2+1).rail0, a(i*2+1).rail1, sleep, t(i));
  end generate;
  ONEMORE: if width rem 2 = 1 generate
    Gsom: th12m_a
      port map(a(width-1).rail0, a(width-1).rail1, sleep, t(width/2));
  end generate;
  

  Gcompodd: if width rem 2 = 1 generate
  begin
    Gco: andtreem
      generic map(width/2+1)
      port map(t, sleep, tko);
    end generate;
    
  Gcompeven: if width rem 2 = 0 generate
  begin
  Gce: andtreem
    generic map(width/2)
    port map(t(width/2-1 downto 0), sleep, tko);
  end generate;
  
  
  Gfgate: th22d_a
    port map(tko, ki, rst, ttko);
  INV1: INV_A
  	port map(ttko, ko);


end arch;




-- Generic Completion (sleep)
library ieee;
use ieee.std_logic_1164.all;
use work.MTNCL_gates.all;
use work.ncl_signals.all;

entity comp1m is
  generic(width: in integer := 4);
   port(a: IN dual_rail_logic_vector(width-1 downto 0);
        ki, kin, rst, sleep: in std_logic;
        ko: OUT std_logic);
end comp1m;

architecture arch of comp1m is

    
        component th33n_a is 
           port(a: in std_logic; 
                b: in std_logic;  
                c: in std_logic;
                rst: in std_logic;
          z: out std_logic ); 
       end component;

	component INV_A is
	port(A : in  std_logic;
	 	Z : out std_logic);
	end component;
        
                component andtreem is
           generic(width: in integer := 4);
           port(a: IN std_logic_vector(width-1 downto 0);
                sleep: in std_logic;
                ko: OUT std_logic);
        end component;
        
        signal t : std_logic_vector(width/2 downto 0);
        signal tko, ttko: std_logic;
begin
  


  STAGE1: for i in 0 to width/2-1 generate
    Gs1: th24compm_a
      port map(a(i*2).rail0,a(i*2).rail1, a(i*2+1).rail0, a(i*2+1).rail1, sleep, t(i));
  end generate;
  ONEMORE: if width rem 2 = 1 generate
    Gsom: th12m_a
      port map(a(width-1).rail0, a(width-1).rail1, sleep, t(width/2));
  end generate;
  

  Gcompodd: if width rem 2 = 1 generate
  begin
    Gco: andtreem
      generic map(width/2+1)
      port map(t, sleep, tko);
    end generate;
    
  Gcompeven: if width rem 2 = 0 generate
  begin
  Gce: andtreem
    generic map(width/2)
    port map(t(width/2-1 downto 0), sleep, tko);
  end generate;
  
  
  Gfgate: th33n_a
    port map(tko, ki, kin, rst, ttko);
    INV1: INV_A
  	port map(ttko, ko);



end arch;

-- Generic Completion (sleep)
library ieee;
use ieee.std_logic_1164.all;
use work.MTNCL_gates.all;
use work.ncl_signals.all;

entity comp1dm is
  generic(width: in integer := 4);
   port(a: IN dual_rail_logic_vector(width-1 downto 0);
        ki, kin, rst, sleep: in std_logic;
        ko: OUT std_logic);
end comp1dm;

architecture arch of comp1dm is

    
        component th33d_a is 
           port(a: in std_logic; 
                b: in std_logic;  
                c: in std_logic;
                rst: in std_logic;
          z: out std_logic ); 
       end component;

	component INV_A is
	port(A : in  std_logic;
	 	Z : out std_logic);
	end component;
        
                component andtreem is
           generic(width: in integer := 4);
           port(a: IN std_logic_vector(width-1 downto 0);
                sleep: in std_logic;
                ko: OUT std_logic);
        end component;
        
        signal t : std_logic_vector(width/2 downto 0);
        signal tko, ttko: std_logic;
begin
  


  STAGE1: for i in 0 to width/2-1 generate
    Gs1: th24compm_a
      port map(a(i*2).rail0,a(i*2).rail1, a(i*2+1).rail0, a(i*2+1).rail1, sleep, t(i));
  end generate;
  ONEMORE: if width rem 2 = 1 generate
    Gsom: th12m_a
      port map(a(width-1).rail0, a(width-1).rail1, sleep, t(width/2));
  end generate;
  

  Gcompodd: if width rem 2 = 1 generate
  begin
    Gco: andtreem
      generic map(width/2+1)
      port map(t, sleep, tko);
    end generate;
    
  Gcompeven: if width rem 2 = 0 generate
  begin
  Gce: andtreem
    generic map(width/2)
    port map(t(width/2-1 downto 0), sleep, tko);
  end generate;
  
  
  Gfgate: th33d_a
    port map(tko, ki, kin, rst, ttko);
  INV1: INV_A
  	port map(ttko, ko);



end arch;
