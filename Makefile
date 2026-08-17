GHDL  ?= ghdl
FLAGS ?= --std=08 -fsynopsys
MODULO ?= 
TB ?=
tempo = --stop-time=1ms

define ghdl_commands
	$(GHDL) -a $(FLAGS) $(2)
	$(GHDL) -e $(FLAGS) $(1)
	$(GHDL) -r $(FLAGS) $(1) $(tempo) --wave=$(1).ghw
endef

.PHONY: all help fsm ula reg_bank memory full_adder wave clean

all: help

fsm:
	$(call ghdl_commands,fsm_tb,cpu/FSM/fsm.vhdl testbench/fsm_tb.vhdl)

ula:
	$(call ghdl_commands,ula_Nbits_tb,cpu/ULA/ula_Nbits.vhdl cpu/ULA/ula_Nbits_tb.vhdl)

reg_bank:
	$(call ghdl_commands,reg_bank_tb,cpu/reg_bank/reg_bank.vhdl testbench/reg_bank_tb.vhdl)

memory:
	$(call ghdl_commands,memory_tb,cpu/memory/memory.vhdl testbench/memory_tb.vhdl)

full_adder:
	$(call ghdl_commands,somador_Nbits_tb,cpu/full_adder/somador_Nbits.vhdl testbench/somador_Nbits_tb.vhdl)

wave:
	gtkwave $(TB).ghw

clean:
	$(GHDL) --clean
	rm -f *.cf *.ghw *.vcd

help:
	@echo "Alvos disponiveis:"
	@echo "  make fsm | ula | reg_bank | memory | full_adder"
	@echo "      -> analisa, elabora e simula (gera <top>.ghw)"
	@echo "  make wave TB=<top>   -> abre a onda no GTKWave (ex: make wave TB=fsm_tb)"
	@echo "  make clean           -> remove artefatos (*.cf *.ghw *.vcd)"