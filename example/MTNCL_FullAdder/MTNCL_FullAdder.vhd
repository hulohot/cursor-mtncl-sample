---------------------------------------------------------------------------
-- MTNCL_FullAdder.vhd
-- 
-- Author: Claude
-- Date: February 25, 2024
--
-- Description:
-- 1-bit Full Adder implemented using MTNCL threshold gates
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MTNCL_gates.all;
use work.NCL_signals.all;

entity MTNCL_FullAdder is
    port (
        a     : in dual_rail_logic;
        b     : in dual_rail_logic;
        cin   : in dual_rail_logic;
        sleep : in std_logic;
        sum   : out dual_rail_logic;
        cout  : out dual_rail_logic
    );
end entity;

architecture structural of MTNCL_FullAdder is
    -- Internal signals for sum calculation
    signal sum_t1, sum_t2, sum_t3, sum_t4 : std_logic;
    
    -- Internal signals for carry calculation
    signal cout_t1, cout_t2, cout_t3 : std_logic;
    
begin
    -- Sum bit calculation
    -- sum.rail1 = (a.rail1 AND b.rail0 AND cin.rail0) OR (a.rail0 AND b.rail1 AND cin.rail0) OR 
    --             (a.rail0 AND b.rail0 AND cin.rail1) OR (a.rail1 AND b.rail1 AND cin.rail1)
    sum_th33_1: th33m_a
        port map(a => a.rail1, b => b.rail0, c => cin.rail0, s => sleep, z => sum_t1);
        
    sum_th33_2: th33m_a
        port map(a => a.rail0, b => b.rail1, c => cin.rail0, s => sleep, z => sum_t2);
        
    sum_th33_3: th33m_a
        port map(a => a.rail0, b => b.rail0, c => cin.rail1, s => sleep, z => sum_t3);
        
    sum_th33_4: th33m_a
        port map(a => a.rail1, b => b.rail1, c => cin.rail1, s => sleep, z => sum_t4);
        
    sum_or_gate: th14m_a
        port map(a => sum_t1, b => sum_t2, c => sum_t3, d => sum_t4, s => sleep, z => sum.rail1);
    
    -- sum.rail0 = (a.rail0 AND b.rail0 AND cin.rail0) OR (a.rail1 AND b.rail1 AND cin.rail0) OR 
    --             (a.rail1 AND b.rail0 AND cin.rail1) OR (a.rail0 AND b.rail1 AND cin.rail1)
    sum_th33_5: th33m_a
        port map(a => a.rail0, b => b.rail0, c => cin.rail0, s => sleep, z => sum_t1);
        
    sum_th33_6: th33m_a
        port map(a => a.rail1, b => b.rail1, c => cin.rail0, s => sleep, z => sum_t2);
        
    sum_th33_7: th33m_a
        port map(a => a.rail1, b => b.rail0, c => cin.rail1, s => sleep, z => sum_t3);
        
    sum_th33_8: th33m_a
        port map(a => a.rail0, b => b.rail1, c => cin.rail1, s => sleep, z => sum_t4);
        
    sum_or_gate_0: th14m_a
        port map(a => sum_t1, b => sum_t2, c => sum_t3, d => sum_t4, s => sleep, z => sum.rail0);
    
    -- Carry out calculation
    -- cout.rail1 = (a.rail1 AND b.rail1) OR (a.rail1 AND cin.rail1) OR (b.rail1 AND cin.rail1)
    cout_th22_1: th22m_a
        port map(a => a.rail1, b => b.rail1, s => sleep, z => cout_t1);
        
    cout_th22_2: th22m_a
        port map(a => a.rail1, b => cin.rail1, s => sleep, z => cout_t2);
        
    cout_th22_3: th22m_a
        port map(a => b.rail1, b => cin.rail1, s => sleep, z => cout_t3);
        
    cout_or_gate: th13m_a
        port map(a => cout_t1, b => cout_t2, c => cout_t3, s => sleep, z => cout.rail1);
    
    -- cout.rail0 = (a.rail0 AND b.rail0) OR (a.rail0 AND cin.rail0) OR (b.rail0 AND cin.rail0)
    cout_th22_4: th22m_a
        port map(a => a.rail0, b => b.rail0, s => sleep, z => cout_t1);
        
    cout_th22_5: th22m_a
        port map(a => a.rail0, b => cin.rail0, s => sleep, z => cout_t2);
        
    cout_th22_6: th22m_a
        port map(a => b.rail0, b => cin.rail0, s => sleep, z => cout_t3);
        
    cout_or_gate_0: th13m_a
        port map(a => cout_t1, b => cout_t2, c => cout_t3, s => sleep, z => cout.rail0);
    
end architecture; 