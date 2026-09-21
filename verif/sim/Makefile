TOP ?= ucie_top
TB ?= ucie_top_tb
FILELIST := filelist.f
TBFILELIST := filelist_tb.f
SNIFFFILELIST := filelist_sniff.f
LINKFILELIST := filelist_link.f
FLITFILELIST := filelist_flit.f

.PHONY: lint sim sniff link flit clean

lint:
	verilator --lint-only -f $(FILELIST) --top-module $(TOP) --timing

sim:
	verilator --binary --timing -j 0 -f $(TBFILELIST) --top-module $(TB) \
	  -Mdir obj_dir_tb -o simv_tb --build -Wno-TIMESCALEMOD
	./obj_dir_tb/simv_tb

sniff:
	verilator --binary --timing -j 0 -f $(SNIFFFILELIST) --top-module sb_sniff_tb \
	  -Mdir obj_dir_sniff -o simv_sniff --build -Wno-TIMESCALEMOD
	./obj_dir_sniff/simv_sniff

link:
	verilator --binary --timing -j 0 -f $(LINKFILELIST) --top-module sb_link_tb \
	  -Mdir obj_dir_link -o simv_link --build -Wno-TIMESCALEMOD
	./obj_dir_link/simv_link

flit:
	verilator --binary --timing -j 0 -f $(FLITFILELIST) --top-module flit_pack_tb \
	  -Mdir obj_dir_flit -o simv_flit --build -Wno-TIMESCALEMOD
	./obj_dir_flit/simv_flit

clean:
	rm -rf obj_dir obj_dir_tb obj_dir_sniff *.vcd *.fst
