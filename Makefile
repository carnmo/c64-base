.ONESHELL:

ifeq ($(OS),Windows_NT)
COMPILER=bin/win/acme.exe
CRUNCHER=bin/win/exomizer.exe
else
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
COMPILER=bin/linux/acme
CRUNCHER=bin/linux/exomizer
endif
ifeq ($(UNAME_S),Darwin)
COMPILER=./bin/macos/acme
CRUNCHER=./bin/macos/exomizer
endif
endif

COMPILER_FLAGS=--format cbm -v3
CRUNCHER_FLAGS=sfx 0x801 -x3 -C
DISKTOOL=c1541
EMULATOR=x64sc -silent -seed 42 +confirmonexit
SOURCES=$(wildcard src/*.asm)
TARGET=c64-base
TARGET_PRG=$(TARGET).prg
TARGET_DISK=$(TARGET).d64

all: compile crunch run

compile:
	$(COMPILER) $(COMPILER_FLAGS) -o $(TARGET_PRG) $(SOURCES)

crunch:
	$(CRUNCHER) $(CRUNCHER_FLAGS) $(TARGET_PRG) -o $(TARGET_PRG)

disk:
	$(DISKTOOL) -format $(TARGET),42 d64 $(TARGET_DISK) -attach $(TARGET_DISK) -write $(TARGET_PRG) $(TARGET)

run:
	$(EMULATOR) ${TARGET_PRG}

clean:
	$(RM) $(TARGET_PRG)
	$(RM) $(TARGET_DISK)
