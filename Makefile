.ONESHELL:
.RECIPEPREFIX = >

COMPILER=bin/acme --format cbm -v3
CRUNCHER=bin/exomizer sfx 0x801 -x3 -C
DISKTOOL=c1541
EMULATOR=x64sc -silent
SOURCES=$(wildcard src/*.asm)
TARGET=c64-base
TARGET_PRG=$(TARGET).prg
TARGET_DISK=$(TARGET).d64

all: compile crunch disk run

compile:
> $(COMPILER) -o $(TARGET_PRG) $(SOURCES)

crunch:
> $(CRUNCHER) $(TARGET_PRG) -o $(TARGET_PRG)

disk:
> $(DISKTOOL) -format $(TARGET),42 d64 $(TARGET_DISK) -attach $(TARGET_DISK) -write $(TARGET_PRG) $(TARGET)

run:
> $(EMULATOR) ${TARGET_DISK}

clean:
> $(RM) $(TARGET_PRG)
> $(RM) $(TARGET_DISK)
