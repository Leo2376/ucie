TOP ?= ucie_top
TB ?= ucie_top_tb
FILELIST := filelist.f
TBFILELIST := filelist_tb.f

.PHONY: lint sim clean

lint:
	verilator --lint-only -f $(FILELIST) --top-module $(TOP) --timing

sim:
	verilator --binary --timing -j 0 -f $(TBFILELIST) --top-module $(TB) \
	  -Mdir obj_dir_tb -o simv_tb --build -Wno-TIMESCALEMOD
	./obj_dir_tb/simv_tb

clean:
	rm -rf obj_dir obj_dir_tb *.vcd *.fst
