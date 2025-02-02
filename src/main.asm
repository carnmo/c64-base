	; TWO TO THE POWER OF NINE
	;
	; A Randy/Origo coop 2025-01
	;
	;  DEMOSCENE FOREVER!
	!cpu 6502
	!to "2pow9.prg",cbm

	* = $0801
	!word entry-2
	!byte $00,$00,$9e
	!text "2066"
	!byte $00,$00,$00

	*= $0812
entry:
	lda #0
	sta $64
	sta $65
	dec $65
	sta $70
	sta $d020
	sta $d021
	lda #$09
	sta $71

	jsr $e544

	sei

	lda #%00110101
	sta $01

	lda #%01111111
	sta $dc0d
	sta $dd0d

	lda #%00000001
	sta $d01a

	lda #%00011011
	sta $d011

	lda #$00
	sta $d012

	ldx #<irq
	stx $fffe
	ldx #>irq
	stx $ffff

	cli

; init sound
	sta $d404   ; voice 1 control
	sta $d40b   ; voice 2 control

	ldx #15
	stx $d418
	stx $d405
	stx $d40c

	lda #5
	sta $d401

	lda #(7<<4)|9
	sta $d406
	lda #(3<<4)|3
	sta $d40d

	lda #17
	sta $d404
	sta $d40b

	jmp *

irq:
	asl $d019

	inc $65
	ldy $65
	cpy #32
	bpl resettext

; write:
	lda ($70),y
	sta $0400+40*12+4,y

	lda #$01
	sta $d800+40*12+4,y
	sta $d012

	rti

; assumes y is $65
resettext:
	lda $70
	cpy #64
	bmi pulse

	clc

	adc #32
	sta $70

	lda #0
	sta $64
	sta $65
	dec $65


pulse:
	and #%00100000
	bne noflash

	cpy #42
	bpl noflash
	lda pulsecolors,y
	sta $d020
	sta $d021
	;lsr
	sta $d016

noflash:
	clc
	adc #5
	and #31
	sta $d401

	tya
	clc
	adc #19
	sta $d408

	rti

pulsecolors:
	!fill 32,0
	!byte $01,$01,$0f,$0f,$0c,$0c,$0b,$0b,$0b,$00

	!align 255,0,0
	!scr "  insane c64 division presents  "
	!scr "                                "
	!scr "    two to the power of nine    "
	!scr "                                "
	!scr "      demoscene forever !!      "
	!scr "                                "
	!scr " greetings to all great friends "
	!scr "                               "
