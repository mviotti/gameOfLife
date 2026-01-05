PROJECT = reverse
DEVICE = GW2A-LV18PG256C8/I7
FAMILY = GW2A-18
BOARD = tangprimer20k
CST = $(PROJECT).cst

all: $(PROJECT).fs

$(PROJECT).json: $(PROJECT).v
	yosys -p "read_verilog $(PROJECT).v; synth_gowin -json $(PROJECT).json -family gw2a"

$(PROJECT)_pnr.json: $(PROJECT).json $(CST)
	nextpnr-himbaechel --json $(PROJECT).json \
		--write $(PROJECT)_pnr.json \
		--device $(DEVICE) \
		--vopt family=$(FAMILY) \
		--vopt cst=$(CST)

$(PROJECT).fs: $(PROJECT)_pnr.json
	gowin_pack -d $(FAMILY) -o $(PROJECT).fs $(PROJECT)_pnr.json

# Programar a SRAM (temporal)
load: $(PROJECT).fs
	openFPGALoader -b $(BOARD) $(PROJECT).fs

# Programar a FLASH (permanente)
flash: $(PROJECT).fs
	openFPGALoader -b $(BOARD) -f $(PROJECT).fs

clean:
	rm -f $(PROJECT).json $(PROJECT)_pnr.json $(PROJECT).fs

.PHONY: all load flash clean
