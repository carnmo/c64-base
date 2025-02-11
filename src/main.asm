	*= $0801

	lda $d018
	sta $64
	jsr $e544
	lda #9
	sta $71

	sei

	lda #%00110101
	sta $01
	sta $d01a
	sta $dc0d

	ldx #<irq 
	stx $fffe
	ldx #>irq
	stx $ffff

	cli

	sta $d404

	lda #15
	sta $d418

	lda #(7<<4)|9
	sta $d406

	lda #17
	sta $d404

	jmp *

irq:
	asl $d019
	inc $65
	ldy $65
	cpy #32
	bpl resettext
	
	lda $64
	sta $d018

	lda ($70),y
	sta $0400+40*12+4,y

	rti

resettext:
	lda $70
	cpy #64
	bmi pulse

	clc
	adc #32
	sta $70

	lda #0
	sta $65
pulse:
	lsr
	lsr
	lsr
	lsr
	sta $d021
	lsr
	and #2
	bne noflash
	cpy #42
	bpl noflash

	lda pulsecolors,y
	sta $d020
	sta $d021
	lsr
	sta $d016
	sta $d018
noflash:
	clc
    adc #5
	and #15
	sta $d401
	lda $d012
	sta $d408
	rti

pulsecolors:
	!fill 32,1
	!byte $01,$01,$0f,$0f,$0c,$0c,$0b,$0b,$00,$00

	!align 255,0,0
	!scr "[f34rl355/num6 )) [f4ll1ng d0wn]"
	!scr "                                "
	!scr " 3ndl355*d3p7h5+0f.my>d4rk-46y55"
	!scr "                                "
	!scr "[f34rl355/num6 )) [f4ll1ng d0wn]"
	!scr "                                "
	!scr " 3ndl355*d3p7h5+0f.my>d4rk-46y55"
	!scr "                                "
