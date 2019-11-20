# -C = Case sensitive labels
# -B = automatic bxx *+3 jmpo $xxxx

EMUDIR = D:\\OneDrive\\X16Dev\\emulator\\x16emu


FILES=\
	layerscroll.asm\
	vera.asm


test.prg: $(FILES)
	64tass -Wall -C -B --line-numbers --verbose-list --tab-size=4 --m65c02 -L layerscroll.lst -o layerscroll.PRG layerscroll.asm
	copy layerscroll.PRG $(EMUDIR)\\layerscroll.PRG
	"D:\\OneDrive\\X16Dev\\emulator\\x16emu\\x16emu" -run -prg "layerscroll.prg"
