# generic CPC-project makefile
# Copyright 2011-2018 PulkoMandy - Shinra! (pulkomandy@pulkomandy.tk)

# TODO
# * I usually do incbin "something.exo" in my sourcecode, but this doesn't get 
#	in the makefile dependancies. Either add something equivalent to gcc -M in 
#	vasm, or find another way... (grep INCBIN + generate dependencies ?)

# GENERIC RULES ###############################################################

# Nice header for doing something
BECHO = @echo -ne "\x1B[46m\t$(1) \x1B[1m$(2)\n\x1B[0m"

vpath %.z80 src

# Run the emulator
emu: $(NAME).sna
	$(call BECHO,"Running emu...")
	cd "/Git/8bit/cpc/ACE1.9" && ./ACE SNAPSHOT=$(realpath $^) PF="print.log" EP

release: $(NAME).zip

$(NAME).zip:: $(NAME).dsk $(NAME).nfo

# Build the DSK-File
%.dsk:
	$(call BECHO,"Putting files in","$@")
	cpcfs $@ f
	for i in $^;do cpcfs $@ p -b -e $$i,0x4000,0x4000 ;done;

# Build the CDT-File
../%.cdt:
	$(call BECHO, "Putting files in $@...")
	j=-n;for i in $^;do 2cdt $$j -r $$i $$i $@;j="";done;

%.sna: %.bin..text
	$(call BECHO, "Creating snapshot $@...")
	createSnapshot $@ \
		-i template.sna \
		-l $^ -1 \
		-s Z80_PC 32768 \
		-f 49152 16384 0

memory.bin memory.C4 memory.C5 memory.C6 memory.C7: $(NAME).sna
	$(call BECHO,"Extracting memory data from ","$@")
	createSnapshot $^ -i $^ \
		-o memory.bin 0x0000 0x10000 \
		-o memory.C4 0x10000 0x4000 \
		-o memory.C5 0x14000 0x4000 \
		-o memory.C6 0x18000 0x4000 \
		-o memory.C7 0x1C000 0x4000

# Build the release zipfile
%.zip: 
	$(call BECHO,"Creating release archive","$@")
	zip $@ $^


# Link the sources ($^ means "all dependencies", so all of them should be .o 
# files - which is good, since anything else should be incbined somewhere)
%.bin..text: build/link.ld
	$(call BECHO,"Linking","$@")
#	vlink -M -Ttext $(START) -b amsdos -o $@ -T$^
	vlink -b amsdos -osec=$(NAME).bin -T$^ -M > $@.map
	
# Assemble the sources
%.o: %.z80
	$(call BECHO,"Assembling","$<")
	vasmz80_oldstyle -Fvobj -o $@ $<

# Crunch a screen
%.exo: %.scr
	$(call BECHO,"Crunching","$<")
	exoraw -o $@ $<.noh

# convert png to cpc screen format
# SCREENMODE can force the screenmode, otherwise it's guessed from the png 
# bitdepth
%.scr: data/%.png
	$(call BECHO,"Converting","$<")
	png2crtc $< $@.noh 7 $(SCREENMODE)
	hideur $@.noh -o $@ -t 2 -l 49152

clean:
	$(call BECHO,"Cleaning","everything")
	rm -f *.exo *.bin *.dsk *.o *.zip *.scr *.noh *.sna
