	;$64 pulse step 0-9
	;$65 charcount
	;$70 pointer to #text

	*= $0801

	lda #0
	sta $64
	sta $65
	dec $65
	sta $70
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

	jsr write
	jsr pulse

	lda #$00
	sta $d012

	lda #<irq
	sta $fffe
	lda #>irq
	sta $ffff

	rti

sound:
	lda #15
	sta $d418

	lda #17
	sta $d401

	lda #240
	sta $d406

	lda #17
	sta $d404

	rts

resettext:
	cpy #100
	bmi k

	lda #0
	sta $64
	sta $65
	dec $65

	clc

	lda $70
	adc #32
	sta $70
k:
	rts

pulse:
	lda pulsecolors,y
	sta $d020
	sta $d021
	rts

write:
	inc $65
	ldy $65
	cpy #32
	bpl resettext

	lda ($70),y
	sta $0400+40*12+4,y
	lda #$01
	sta $d800+40*12+4,y
	rts

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
