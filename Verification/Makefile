TC ?= axi_spi_rand_test
SEED ?= 1234

VCS_OPTS := -full64 -sverilog 
VCS_OPTS += -ntb_opts uvm-1.2 # 필요 없는건 주석처리하면서 쓸 수 있어서 편하다.
VCS_OPTS += -timescale=1ns/1ps
VCS_OPTS += -debug_access+all -kdb -lca
VCS_OPTS += +incdir+./tb
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert   # 커버리지 옵션이다. line coverage, fsm coverage 등

SIM_OPTS := +UVM_VERBOSITY=UVM_HIGH # 출력 레벨
SIM_OPTS += +ntb_random_seed=$(SEED)
# SIM_OPTS += +UVM_TESTNAME=$(TC)
SIM_OPTS += -cm line+cond+fsm+tgl+branch+assert   # 커버리지 관련.
SIM_OPTS += -cm_dir coverage.vdb
SIM_OPTS += -cm_name sim1  # 커버리지 name

VERDI_OPTS := -dbdir simv.daidir -ssf novas.fsdb

.PHONY: compile sim clean  # target name

compile:
	vcs $(VCS_OPTS) -f filelist.f -o simv 
# 	@echo "타겟 [$@] 완료"

sim: compile
	./simv $(SIM_OPTS) +UVM_TESTNAME=axi_spi_corner_test

# verdi: sim
# 	verdi $(VERDI_OPTS) &

# verdi waveform
vw: sim
	verdi -dbdir simv.daidir -ssf novas.fsdb &

# verdi coverage
vc: sim
	verdi -cov -covdir coverage.vdb &

clean:
	rm -rf simv* csrc *.key *.h *.log *.fsdb novas* *.conf *Log *.vdb
