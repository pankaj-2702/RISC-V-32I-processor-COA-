IVERILOG = iverilog
VVP = vvp

RTL = rtl/*.v
TB = tb/*.v

.PHONY: all test clean

all: test

test:
	@mkdir -p sim
	$(IVERILOG) -g2012 -I rtl -o sim/tb_cpu $(RTL) tb/tb_cpu.v
	$(VVP) sim/tb_cpu

clean:
	rm -f sim/*
