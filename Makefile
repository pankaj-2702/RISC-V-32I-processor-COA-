
IVERILOG := iverilog
VVP      := vvp

RTL_DIR  := rtl
TB_DIR   := tb
SIM_DIR  := sim
WAVE_DIR := build

RTL_FILES := $(wildcard $(RTL_DIR)/*.v)
TB_FILES  := $(wildcard $(TB_DIR)/tb_*.v)

TESTS := $(patsubst tb_%,%,$(basename $(notdir $(TB_FILES))))

IVERILOG_FLAGS := -g2012 -I $(RTL_DIR)

.PHONY: all test clean list $(TESTS)

all: test

# Compile and run every testbench
test:
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	@set -e; \
	for t in $(TESTS); do \
		$(MAKE) --no-print-directory $$t; \
	done
	@echo ""
	@echo "All testbench simulations completed."

# Run one testbench, e.g. make alu or make cpu
$(TESTS):
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)

	@echo "Testing: $@"
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_DIR)/tb_$@.vvp $(RTL_FILES) $(TB_DIR)/tb_$@.v
	$(VVP) $(SIM_DIR)/tb_$@.vvp

# Display available testbench names
list:
	@echo "Available testbenches:"
	@for t in $(TESTS); do echo "  make $$t"; done

# Remove generated simulation outputs and waveforms
clean:
	rm -f $(SIM_DIR)/*.vvp $(SIM_DIR)/*.out
	rm -f $(WAVE_DIR)/*.vcd
	@echo "Generated simulation files removed."
