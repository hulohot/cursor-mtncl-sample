# Makefile for MTNCL simulations

# Default simulator
SIM ?= questasim

# Common paths
COMMON_DIR = ../../common
RUN_DIR = ./run
VECTOR_DIR = ./vectors

# MTNCL component name (used for file naming)
COMPONENT ?= FullAdder

# Design files
SOURCES = $(COMMON_DIR)/NCL_signals.vhd \
          $(COMMON_DIR)/NCL_functions.vhd \
          $(COMMON_DIR)/MTNCL_gates.vhd \
          $(COMMON_DIR)/MTNCL_package.vhd \
          $(COMMON_DIR)/MTNCL_completion.vhd \
          $(COMMON_DIR)/MTNCL_registers.vhd \
          ./MTNCL_$(COMPONENT).vhd

# Testbench
TB = MTNCL_$(COMPONENT)_tb.py
TB_TOP = MTNCL_$(COMPONENT)

# Pipeline stage testbench
STAGE_TB = MTNCL_$(COMPONENT)_Stage_tb.py
STAGE_TB_TOP = MTNCL_$(COMPONENT)_Stage
STAGE_SOURCES = $(SOURCES) ./MTNCL_$(COMPONENT)_Stage.vhd

# Check if running on Apple Silicon
ARCH := $(shell uname -m)
ifeq ($(ARCH), arm64)
    # Use Rosetta 2 for x86_64 compatibility on Apple Silicon
    ARCH_PREFIX := arch -x86_64
else
    ARCH_PREFIX :=
endif

# Enable waveform generation
WAVES ?= 0
ifeq ($(WAVES), 1)
    COCOTB_RESULTS_FILE = $(RUN_DIR)/results.xml
    COCOTB_HOOK = $(RUN_DIR)/waveforms.hook.py
    PLUSARGS += -fst
    PLUSARGS += +fsdb+functions
    PLUSARGS += -debug-all
endif

# Targets for different simulators
ifeq ($(SIM), ghdl)
	COCOTB_HDL_TIMEUNIT = 1ns
	COCOTB_HDL_TIMEPRECISION = 1ps
	SIM_BUILD = $(RUN_DIR)/sim_build_ghdl
	VHDL_SOURCES = $(SOURCES)
	TOPLEVEL_LANG = vhdl
endif

ifeq ($(SIM), iverilog)
	COCOTB_HDL_TIMEUNIT = 1ns
	COCOTB_HDL_TIMEPRECISION = 1ps
	SIM_BUILD = $(RUN_DIR)/sim_build_iverilog
	COMPILE_ARGS = -g2012
	VHDL_SOURCES = $(SOURCES)
	TOPLEVEL_LANG = vhdl
endif

ifeq ($(SIM), verilator)
	COCOTB_HDL_TIMEUNIT = 1ns
	COCOTB_HDL_TIMEPRECISION = 1ps
	SIM_BUILD = $(RUN_DIR)/sim_build_verilator
	COMPILE_ARGS = --timing
	VHDL_SOURCES = $(SOURCES)
	TOPLEVEL_LANG = vhdl
endif

ifeq ($(SIM), questa)
	COCOTB_HDL_TIMEUNIT = 1ns
	COCOTB_HDL_TIMEPRECISION = 1ps
	SIM_BUILD = $(RUN_DIR)/sim_build_questa
	VSIM_ARGS = -voptargs=+acc
	VHDL_SOURCES = $(SOURCES)
	TOPLEVEL_LANG = vhdl
endif

ifeq ($(SIM), vcs)
	COCOTB_HDL_TIMEUNIT = 1ns
	COCOTB_HDL_TIMEPRECISION = 1ps
	SIM_BUILD = $(RUN_DIR)/sim_build_vcs
	COMPILE_ARGS = -debug_pp
	VHDL_SOURCES = $(SOURCES)
	TOPLEVEL_LANG = vhdl
endif

# Waveform hook file
$(RUN_DIR)/waveforms.hook.py:
	mkdir -p $(RUN_DIR)
	echo "import cocotb" > $@
	echo "from cocotb.triggers import Timer" >> $@
	echo "@cocotb.hook()" >> $@
	echo "def setup_dumpfile(sim):" >> $@
	echo "    sim.write_vcd('$(RUN_DIR)/waveform.vcd')" >> $@

# Targets
.PHONY: all clean waves vectors stage stage_waves debug

debug:
	@echo "Architecture: $(ARCH)"
	@echo "ARCH_PREFIX: $(ARCH_PREFIX)"
	@echo "TB: $(TB)"
	@echo "TB_TOP: $(TB_TOP)"
	@echo "SOURCES: $(SOURCES)"
	@echo "SIM: $(SIM)"
	@echo "VHDL_SOURCES: $(VHDL_SOURCES)"
	@echo "TOPLEVEL_LANG: $(TOPLEVEL_LANG)"
	@echo "COCOTB_MAKEFILES: $$(cocotb-config --makefiles)"

all: $(RUN_DIR)/results.csv

$(RUN_DIR)/results.csv: $(TB) $(if $(filter 1,$(WAVES)),$(COCOTB_HOOK),)
	@echo "Running testbench $(TB) with simulator $(SIM)"
	mkdir -p $(RUN_DIR)
	$(ARCH_PREFIX) bash -c "set -x && PYTHONPATH=$(PYTHONPATH):$(PWD):$(PWD)/.. make -f $$(cocotb-config --makefiles)/Makefile.sim \
		SIM=$(SIM) TOPLEVEL=$(TB_TOP) MODULE=$(TB:%.py=%) VHDL_SOURCES=\"$(SOURCES)\" VERBOSE=1"

stage: $(RUN_DIR)/stage_results.csv

$(RUN_DIR)/stage_results.csv: $(STAGE_TB) $(if $(filter 1,$(WAVES)),$(COCOTB_HOOK),)
	@echo "Running stage testbench $(STAGE_TB) with simulator $(SIM)"
	mkdir -p $(RUN_DIR)
	$(ARCH_PREFIX) bash -c "set -x && PYTHONPATH=$(PYTHONPATH):$(PWD):$(PWD)/.. make -f $$(cocotb-config --makefiles)/Makefile.sim \
		SIM=$(SIM) TOPLEVEL=$(STAGE_TB_TOP) MODULE=$(STAGE_TB:%.py=%) VHDL_SOURCES=\"$(STAGE_SOURCES)\" VERBOSE=1"

waves: WAVES=1
waves: all
	@echo "Waveform generated at $(RUN_DIR)/waveform.vcd"
	@if command -v gtkwave >/dev/null 2>&1; then \
		gtkwave $(RUN_DIR)/waveform.vcd & \
	else \
		echo "GTKWave not found. Install it to view the waveform."; \
	fi

stage_waves: WAVES=1
stage_waves: stage
	@echo "Waveform generated at $(RUN_DIR)/waveform.vcd"
	@if command -v gtkwave >/dev/null 2>&1; then \
		gtkwave $(RUN_DIR)/waveform.vcd & \
	else \
		echo "GTKWave not found. Install it to view the waveform."; \
	fi

vectors:
	mkdir -p $(VECTOR_DIR)
	$(ARCH_PREFIX) python -c "import sys; sys.path.append('$(PWD)/..'); from mtncl_utils import generate_test_vectors; generate_test_vectors(20, 1, '$(VECTOR_DIR)/full_adder_test_vectors.csv')"
	$(ARCH_PREFIX) python -c "import sys; sys.path.append('$(PWD)/..'); from mtncl_utils import generate_test_vectors; generate_test_vectors(20, 1, '$(VECTOR_DIR)/full_adder_stage_test_vectors.csv')"

clean:
	rm -rf $(RUN_DIR) 