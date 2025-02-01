	*= $0801

	lda #0
	sta $64
	sta $65
	dec $65
	sta $70
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

	;lda #%11001000
	;sta $d016

	lda #$00
	sta $d012

	lda #<irq 
	sta $fffe
	lda #>irq
	sta $ffff
	
	cli
	
	jmp *

irq:
	asl $d019

	inc $65
	ldy $65
	cpy #32
	bpl resettext

	lda ($70),y
	sta $0400+40*12+4,y
	lda #$01
	sta $d800+40*12+4,y
	sta $d012

	rti

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


; assumes y is $65
pulse:
	lsr
	lsr
	lsr
	lsr
	lsr
	and #1
	bne noflash

	lda pulsecolors,y
	sta $d020
	sta $d021

noflash:
	
	lda #15
	sta $d418

	lda #17
	sta $d401

	lda #240
	sta $d406

	lda #17
	sta $d404
	
	rti


pulsecolors:
	!fill 32,0
	!byte $01,$01,$0f,$0f,$0c,$0c,$0b,$0b,$00,$00

	!align 255,0,0
	!scr "first line of text first line of"
	!scr "                                "
	!scr "second line of text first line o"
	!scr "                                "
	!scr "third line of text first line of"
	!scr "                                "
	!scr "fourthline of text first line of"
	!scr "                                "
	;!byte $0
