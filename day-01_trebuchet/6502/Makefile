.PHONY: all env clean chr

NAME = day1
NESCFG = nes_nrom.cfg
CAFLAGS = -g -t nes
LDFLAGS = -C $(NESCFG) --dbgfile bin/$(NAME).dbg -m bin/$(NAME).map

SOURCES = \
	main.asm

CHR = font.chr

all: bin/ bin/$(NAME).nes

clean:
	-rm bin/*

bin/:
	-mkdir bin

bin/$(NAME).nes: bin/main.o
	ld65 $(LDFLAGS) -o $@ $^

bin/main.o: $(SOURCES) $(CHR)
	ca65 $(CAFLAGS) -o $@ main.asm

