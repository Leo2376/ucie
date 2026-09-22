TOP ?= ucie_top
TB ?= ucie_top_tb
FILELIST := filelist.f
TBFILELIST := filelist_tb.f
SNIFFFILELIST := filelist_sniff.f
LINKFILELIST := filelist_link.f
FLITFILELIST := filelist_flit.f
FLITPATHFILELIST := filelist_flitpath.f
FLITSTRESSFILELIST := filelist_flitstress.f
LINKMGMTFILELIST := filelist_linkmgmt.f
LANEPLLFILELIST := filelist_lanepll.f

.PHONY: lint sim sniff link flit flit_path flit_stress link_mgmt lane_pll regress clean

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

flit_path:
	verilator --binary --timing -j 0 -f $(FLITPATHFILELIST) --top-module flit_path_tb \
	  -Mdir obj_dir_flitpath -o simv_flitpath --build -Wno-TIMESCALEMOD
	./obj_dir_flitpath/simv_flitpath

flit_stress:
	verilator --binary --timing -j 0 -f $(FLITSTRESSFILELIST) --top-module flit_stress_tb \
	  -Mdir obj_dir_flitstress -o simv_flitstress --build -Wno-TIMESCALEMOD
	./obj_dir_flitstress/simv_flitstress

link_mgmt:
	verilator --binary --timing -j 0 -f $(LINKMGMTFILELIST) --top-module link_mgmt_tb \
	  -Mdir obj_dir_linkmgmt -o simv_linkmgmt --build -Wno-TIMESCALEMOD
	./obj_dir_linkmgmt/simv_linkmgmt

lane_pll:
	verilator --binary --timing -j 0 -f $(LANEPLLFILELIST) --top-module lane_pll_tb \
	  -Mdir obj_dir_lanepll -o simv_lanepll --build -Wno-TIMESCALEMOD
	./obj_dir_lanepll/simv_lanepll

regress:
	./regress.sh

clean:
	rm -rf obj_dir* *.vcd *.fst
