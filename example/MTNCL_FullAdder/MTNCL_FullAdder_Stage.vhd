---------------------------------------------------------------------------
-- MTNCL_FullAdder_Stage.vhd
-- 
-- Author: Claude
-- Date: February 25, 2024
--
-- Description:
-- Complete pipeline stage with input register, 1-bit full adder, and
-- output register with completion detection.
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MTNCL_gates.all;
use work.NCL_signals.all;

entity MTNCL_FullAdder_Stage is
    port (
        a     : in dual_rail_logic;
        b     : in dual_rail_logic;
        cin   : in dual_rail_logic;
        sleep : in std_logic;
        ki    : in std_logic;
        ko    : out std_logic;
        sum   : out dual_rail_logic;
        cout  : out dual_rail_logic
    );
end entity;

architecture structural of MTNCL_FullAdder_Stage is
    -- Component signals
    signal a_reg, b_reg, cin_reg : dual_rail_logic;
    signal sum_comb, cout_comb : dual_rail_logic;
    signal ko_temp : std_logic;
    
    -- Output signals for completion detection
    signal output_bus : dual_rail_logic_vector(1 downto 0);
    
begin
    -- Input registers
    reg_a : entity work.regm
        port map (
            a => a,
            s => sleep,
            z => a_reg
        );
    
    reg_b : entity work.regm
        port map (
            a => b,
            s => sleep,
            z => b_reg
        );
    
    reg_cin : entity work.regm
        port map (
            a => cin,
            s => sleep,
            z => cin_reg
        );
    
    -- Combinational logic section (Full Adder)
    full_adder : entity work.MTNCL_FullAdder
        port map (
            a => a_reg,
            b => b_reg,
            cin => cin_reg,
            sleep => sleep,
            sum => sum_comb,
            cout => cout_comb
        );
    
    -- Output registers
    reg_sum : entity work.regm
        port map (
            a => sum_comb,
            s => sleep,
            z => sum
        );
    
    reg_cout : entity work.regm
        port map (
            a => cout_comb,
            s => sleep,
            z => cout
        );
    
    -- Prepare output bus for completion detection
    output_bus(0) <= sum;
    output_bus(1) <= cout;
    
    -- Completion detection
    comp : entity work.compm
        generic map (
            width => 2
        )
        port map (
            a => output_bus,
            ki => ki,
            ko => ko_temp
        );
    
    ko <= ko_temp;
end architecture; 