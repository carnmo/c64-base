.ONESHELL:
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
COMPILER=acme --format cbm -v3
CRUNCHER=./bin/exomizer sfx 0x801 -x3 -C
else
COMPILER=bin/acme --format cbm -v3 --initmem 1
CRUNCHER=bin/exomizer sfx 0x801 -x3 -C
endif
DISKTOOL=c1541
EMULATOR=x64sc -silent -seed 42 +confirmonexit
SOURCES=$(wildcard src/*.asm)
TARGET=c64-base
TARGET_PRG=$(TARGET).prg
TARGET_DISK=$(TARGET).d64

all: compile crunch run

compile:
	$(COMPILER) -o $(TARGET_PRG) $(SOURCES)

crunch:
	$(CRUNCHER) $(TARGET_PRG) -o $(TARGET_PRG)

disk:
	$(DISKTOOL) -format $(TARGET),42 d64 $(TARGET_DISK) -attach $(TARGET_DISK) -write $(TARGET_PRG) $(TARGET)

run:
	$(EMULATOR) ${TARGET_PRG}

clean:
	$(RM) $(TARGET_PRG)
	$(RM) $(TARGET_DISK)
