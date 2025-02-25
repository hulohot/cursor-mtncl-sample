import cocotb
from cocotb.triggers import Timer
@cocotb.hook()
def setup_dumpfile(sim):
    sim.write_vcd('run/waveform.vcd')
