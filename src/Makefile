# -C = Case sensitive labels
# -B = automatic bxx *+3 jmpo $xxxx

# Currently this is set up for windows, but it's not hard to convert to Linux
# I haven't had time to make it cross platform. 

# Location of folder containing the x16emu emulator
EMUDIR = D:\\OneDrive\\X16Dev\\emulator\\x16emu

# Folder containing the compiled vera.lib	
LIBRARIES = D:\\OneDrive\\X16Dev\\source\\lib
# Folder containing the vera.h file from veralib
INCLUDE = D:\\OneDrive\\X16Dev\\source\\header


FILES=\
	layerscroll.c

layerscroll.prg: $(FILES)
	cc65 -t cx16 -I $(INCLUDE) layerscroll.c
	ca65 -t cx16 layerscroll.s
	ld65 -t cx16 -L $(LIBRARIES) -o layerscroll.prg layerscroll.o vera.lib cx16.lib
	copy layerscroll.prg $(EMUDIR)
	-echo y | del *.s
	-echo y | del *.o
	-echo y | del *.prg
	$(EMUDIR)\\x16emu -run -debug -prg "$(EMUDIR)\\layerscroll.prg"