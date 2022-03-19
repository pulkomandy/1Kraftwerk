NAME=1KRAFT

SCREENMODE=1

$(NAME).dsk:: $(NAME).BIN

$(NAME).BIN: payload.zx7 dzx7_standard.asm
	$(call BECHO,"Generating loader...")
	vasmz80_oldstyle -o $@ dzx7_standard.asm -Fbin

payload.zx7: $(NAME).bin..text
	$(call BECHO,"Packing $@")
	rm -f $@
	dd if=$< of=tmp bs=128 skip=1
	zx7 tmp $@
	rm tmp

$(NAME).bin..text:: intro.o

include build/cpc.mk
