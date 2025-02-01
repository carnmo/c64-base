# c64-base

Toolkit for cross compiling MOS Technology 6502 assembly code for the Commodore 64.

## Requirements

- make
- vice

### Install on MacOS:

`brew install acme vice`

`git clone https://bitbucket.org/magli143/exomizer.git`

`(cd exomizer/src/; make; cp exomizer ../../bin/)`

## Usage

`make`

## Notes

- `acme` version 0.97 and `exomizer` version 3.1.3b0 was built from source using `gcc` version 14.2.1 on Arch Linux.
- `c1541` and `x64sc` version 3.9 is part of [Vice](https://vice-emu.sourceforge.io/).
