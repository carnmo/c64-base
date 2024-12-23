;                       ________.        .______.     ._____.
;     ___________ ______\___    |______  |      |_____|     |        ._____.
;  .__\___      /_\       __    .      \ |      :    __     |_______ |     | 
;  |     /         \      \|    :     \ \|           \|            /_|     |  
;  |_____\______________________|\_____\        :___________:________      |  
;                                       \_______|              /___________|  

	;0-39
	characterindex = $64

	;0-24
	rowindex = $65

	;0-15
	cursorcolorindex = $67

	;0 = pause
	;1 = write
	;2 = fade
	state = $68
	
	counter = $69

	colormempointer = $80
	screenmempointer = $82
	textpointer = $84

	screenmem = $0400
	charset = $3800
	cursorcolors = $42aa
	fadecolors = $42d0
	text = $4440
	colormem = $d800

	*= $0801

	lda #$00
	sta $d020
	sta $d021
	
	jsr setpointers
	jsr setstatepause

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

	lda #%11001000
	sta $d016

	lda #%00011110
	sta $d018

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

	jsr getstate
	jsr writecursor

	lda #$00
	sta $d012

	lda #<irq
	sta $fffe
	lda #>irq
	sta $ffff

	rti

dissolve:
	lda counter
	cmp #$00
	beq dissolvedone

	jsr fadescreen

	dec counter
	rts

getstate:
	lda state
	cmp #$01
	beq writecharacter
	bpl dissolve
	bmi countdown
	rts

fadescreen:
	ldx counter
	lda fadecolors,x
	ldy #$00
-
	sta colormem,y
	sta colormem + 255,y
	sta colormem + 255 * 2,y

	iny
	bne -

	ldy #$00
-
	sta colormem + 255 * 3,y

	iny
	cpy #235
	bne -
	rts

dissolvedone:
	jsr advancescreen
	jsr setstatewrite
	jsr clearscreen
	rts

writecursor:
	ldx cursorcolorindex
	ldy characterindex
	lda cursorcolors,x
	sta (colormempointer),y

	lda #$40
	sta (screenmempointer),y

	lda cursorcolorindex
	cmp #26
	beq resetcursorcolor
	inc cursorcolorindex
	rts

resetcursorcolor:
	lda #$00
	sta cursorcolorindex
	rts

countdown:
	lda counter
	cmp #$00
	beq advancescreen
	dec counter
	rts

advancescreen:
	jsr setstatedissolve
	jsr clearindices
	jsr setcolorpointer
	jsr setscreenpointer
	rts

clearscreen:
	lda #$20
	ldx #$00
-
	sta screenmem,x
	sta screenmem + 255,x
	sta screenmem + 255 * 2,x

	inx
	bne -

	ldx #$00
-
	sta screenmem + 255 * 3,x

	inx
	cpx #235
	bne -
	rts

writecharacter:
	jsr getcolor

	ldy characterindex
	lda (textpointer),y
	cmp #$ff
	beq setpointers

	sta (screenmempointer),y
	cpy #39
	beq nextrow

	inc characterindex
	rts

getcolor:
	ldy characterindex
	lda #$01
	sta (colormempointer),y
	rts

pushpointeroffsets:
	clc

	lda colormempointer
	adc #40
	sta colormempointer
	lda colormempointer + 1
	adc #$00
	sta colormempointer + 1

	lda screenmempointer
	adc #40
	sta screenmempointer
	lda screenmempointer + 1
	adc #$00
	sta screenmempointer + 1
	rts

pushtextpointeroffset:
	clc

	lda textpointer
	adc #40
	sta textpointer
	
	lda textpointer + 1
	adc #$00
	sta textpointer + 1
	rts

nextrow:
	jsr pushtextpointeroffset

	lda rowindex
	cmp #24
	beq setstatepause

	jsr pushpointeroffsets

	lda #$00
	sta characterindex

	inc rowindex
	rts

setstatepause:
	lda #$00
	sta state
	
	lda #$7f
	sta counter
	rts

setstatewrite:
	lda #$01
	sta state
	rts

setstatedissolve:
	lda #$02
	sta state
	
	lda #31
	sta counter
	rts

setpointers:
	jsr clearindices
	jsr setcolorpointer
	jsr setscreenpointer
	jsr settextpointer
	jsr clearscreen
	rts

clearindices:
	lda #$00
	sta characterindex
	sta rowindex
	sta cursorcolorindex
	rts

setcolorpointer:
	lda #<colormem
	sta colormempointer
	lda #>colormem
	sta colormempointer + 1
	rts

setscreenpointer:
	lda #<screenmem
	sta screenmempointer
	lda #>screenmem
	sta screenmempointer + 1
	rts

settextpointer:
	lda #<text
	sta textpointer
	lda #>text
	sta textpointer + 1
	rts

	*= charset
	;@
	!byte %01111100
	!byte %11000110
	!byte %11011110
	!byte %11011110
	!byte %11011100
	!byte %11000000
	!byte %01111100
	!byte %00000000
	;a
	!byte %01111100
	!byte %11000110
	!byte %11000110
	!byte %11111110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %00000000
	;b
	!byte %11111100
	!byte %11000110
	!byte %11000110
	!byte %11111100
	!byte %11000110
	!byte %11000110
	!byte %11111100
	!byte %00000000
	;c
	!byte %01111110
	!byte %11000000
	!byte %11000000
	!byte %11000000
	!byte %11000000
	!byte %11000000
	!byte %01111110
	!byte %00000000
	;d
	!byte %11111100
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11111100
	!byte %00000000
	;e
	!byte %01111110
	!byte %11000000
	!byte %11000000
	!byte %11111100
	!byte %11000000
	!byte %11000000
	!byte %01111110
	!byte %00000000
	;f
	!byte %01111110
	!byte %11000000
	!byte %11000000
	!byte %11111100
	!byte %11000000
	!byte %11000000
	!byte %11000000
	!byte %00000000
	;g
	!byte %01111100
	!byte %11000000
	!byte %11000000
	!byte %11011110
	!byte %11000110
	!byte %11000110
	!byte %01111100
	!byte %00000000
	;h
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11111110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %00000000
	;i
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00000000
	;j
	!byte %00000110
	!byte %00000110
	!byte %00000110
	!byte %00000110
	!byte %00000110
	!byte %11000110
	!byte %01111100
	!byte %00000000
	;k
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11111100
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %00000000
	;l
	!byte %11000000
	!byte %11000000
	!byte %11000000
	!byte %11000000
	!byte %11000000
	!byte %11000000
	!byte %01111110
	!byte %00000000
	;m
	!byte %11000110
	!byte %11101110
	!byte %11010110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %00000000
	;n
	!byte %11000110
	!byte %11100110
	!byte %11110110
	!byte %11011110
	!byte %11001110
	!byte %11000110
	!byte %11000110
	!byte %00000000
	;o
	!byte %01111100
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %01111100
	!byte %00000000
	;p
	!byte %11111100
	!byte %11000110
	!byte %11000110
	!byte %11111100
	!byte %11000000
	!byte %11000000
	!byte %11000000
	!byte %00000000
	;q
	!byte %01111100
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11010110
	!byte %11001110
	!byte %01111100
	!byte %00000000
	;r
	!byte %11111100
	!byte %11000110
	!byte %11000110
	!byte %11111100
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %00000000
	;s
	!byte %01111110
	!byte %11000000
	!byte %11000000
	!byte %01111100
	!byte %00000110
	!byte %00000110
	!byte %11111100
	!byte %00000000
	;t
	!byte %11111100
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00000000
	;u
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %01111100
	!byte %00000000
	;v
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %01101100
	!byte %00111000
	!byte %00000000
	;w
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %11010110
	!byte %11111110
	!byte %11101110
	!byte %11000110
	!byte %00000000
	;x
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %01111100
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %00000000
	;y
	!byte %11001100
	!byte %11001100
	!byte %11001100
	!byte %01111000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00000000
	;z
	!byte %11111110
	!byte %00001100
	!byte %00011000
	!byte %00110000
	!byte %01100000
	!byte %11000000
	!byte %11111110
	!byte %00000000
	;[
	!byte %01111110
	!byte %01100000
	!byte %01100000
	!byte %01100000
	!byte %01100000
	!byte %01100000
	!byte %01111110
	!byte %00000000
	;£
	!byte %00111100
	!byte %01100110
	!byte %01100000
	!byte %01100000
	!byte %11111000
	!byte %01100000
	!byte %11111100
	!byte %00000000
	;]
	!byte %11111100
	!byte %00001100
	!byte %00001100
	!byte %00001100
	!byte %00001100
	!byte %00001100
	!byte %11111100
	!byte %00000000
	;arrow-up
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	;arrow-left
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	;space
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	;!
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00000000
	!byte %00110000
	!byte %00000000
	;"
	!byte %01100110
	!byte %01100110
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	;#
	!byte %01101100
	!byte %01101100
	!byte %11111110
	!byte %01101100
	!byte %11111110
	!byte %01101100
	!byte %01101100
	!byte %00000000
	;$
	!byte %00110000
	!byte %01111110
	!byte %11000000
	!byte %01111100
	!byte %00000110
	!byte %11111100
	!byte %00110000
	!byte %00000000
	;%
	!byte %00000000
	!byte %11000110
	!byte %11001100
	!byte %00011000
	!byte %00110000
	!byte %01100110
	!byte %11000110
	!byte %00000000
	;&
	!byte %01111000
	!byte %11001100
	!byte %11011000
	!byte %01111100
	!byte %11011010
	!byte %11001100
	!byte %01110110
	!byte %00000000
	;'
	!byte %00110000
	!byte %00110000
	!byte %01100000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	;(
	!byte %00111100
	!byte %01100000
	!byte %11000000
	!byte %11000000
	!byte %11000000
	!byte %01100000
	!byte %00111100
	!byte %00000000
	;)
	!byte %01111000
	!byte %00001100
	!byte %00000110
	!byte %00000110
	!byte %00000110
	!byte %00001100
	!byte %01111000
	!byte %00000000
	;*
	!byte %00000000
	!byte %01101100
	!byte %00111000
	!byte %11111110
	!byte %00111000
	!byte %01101100
	!byte %00000000
	!byte %00000000
	;+
	!byte %00000000
	!byte %00011000
	!byte %00011000
	!byte %01111110
	!byte %00011000
	!byte %00011000
	!byte %00000000
	!byte %00000000
	;,
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00110000
	!byte %00110000
	!byte %01100000
	!byte %00000000
	;-
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %11111110
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	;.
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00000000
	!byte %00110000
	!byte %00110000
	!byte %00000000
	;/
	!byte %00000000
	!byte %00000110
	!byte %00001100
	!byte %00011000
	!byte %00110000
	!byte %01100000
	!byte %11000000
	!byte %00000000
	;0
	!byte %01111100
	!byte %11000110
	!byte %11001110
	!byte %11010110
	!byte %11100110
	!byte %11000110
	!byte %01111100
	!byte %00000000
	;1
	!byte %00110000
	!byte %01110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00110000
	!byte %00000000
	;2
	!byte %01111100
	!byte %11000110
	!byte %00001100
	!byte %00011000
	!byte %00110000
	!byte %01100000
	!byte %11111110
	!byte %00000000
	;3
	!byte %11111100
	!byte %00000110
	!byte %00000110
	!byte %01111100
	!byte %00000110
	!byte %00000110
	!byte %11111100
	!byte %00000000
	;4
	!byte %11000110
	!byte %11000110
	!byte %11000110
	!byte %01111110
	!byte %00000110
	!byte %00000110
	!byte %00000110
	!byte %00000000
	;5
	!byte %11111110
	!byte %11000000
	!byte %11000000
	!byte %11111100
	!byte %00000110
	!byte %00000110
	!byte %11111100
	!byte %00000000
	;6
	!byte %01111100
	!byte %11000000
	!byte %11000000
	!byte %11111100
	!byte %11000110
	!byte %11000110
	!byte %01111100
	!byte %00000000
	;7
	!byte %11111100
	!byte %00000110
	!byte %00000110
	!byte %00111110
	!byte %00000110
	!byte %00000110
	!byte %00000110
	!byte %00000000
	;8
	!byte %01111100
	!byte %11000110
	!byte %11000110
	!byte %01111100
	!byte %11000110
	!byte %11000110
	!byte %01111100
	!byte %00000000
	;9
	!byte %01111100
	!byte %11000110
	!byte %11000110
	!byte %01111110
	!byte %00000110
	!byte %00000110
	!byte %00000110
	!byte %00000000
	;:
	!byte %00000000
	!byte %00110000
	!byte %00110000
	!byte %00000000
	!byte %00000000
	!byte %00110000
	!byte %00110000
	!byte %00000000
	;;
	!byte %00000000
	!byte %00110000
	!byte %00110000
	!byte %00000000
	!byte %00000000
	!byte %00110000
	!byte %01100000
	!byte %00000000
	;<
	!byte %00011100
	!byte %00110000
	!byte %01100000
	!byte %11000000
	!byte %01100000
	!byte %00110000
	!byte %00011100
	!byte %00000000
	;=
	!byte %00000000
	!byte %00000000
	!byte %11111100
	!byte %00000000
	!byte %00000000
	!byte %11111100
	!byte %00000000
	!byte %00000000
	;>
	!byte %01110000
	!byte %00011000
	!byte %00001100
	!byte %00000110
	!byte %00001100
	!byte %00011000
	!byte %01110000
	!byte %00000000
	;?
	!byte %01111100
	!byte %11000110
	!byte %00000110
	!byte %00111100
	!byte %00110000
	!byte %00000000
	!byte %00110000
	!byte %00000000
	;$40, cursor
	!byte %11111111
	!byte %11111111
	!byte %11111111
	!byte %11111111
	!byte %11111111
	!byte %11111111
	!byte %11111111
	!byte %11111111
	;heart (A)
	!byte %01101100
	!byte %11111110
	!byte %11111110
	!byte %11111110
	!byte %01111100
	!byte %00111000
	!byte %00010000
	!byte %00000000

	*= cursorcolors
	!byte $01,$01,$01,$01,$0f,$0f,$0f,$0f,$0c,$0c,$0c,$0c,$02,$02,$02,$0c,$0c,$0c,$0c,$0f,$0f,$0f,$0f,$01,$01,$01,$01

	*= fadecolors
	!byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$07,$07,$07,$07,$07,$07,$07,$07
	!byte $00,$0b1,$00,$00,$00,$01,$01,$00,$0c,$01,$00,$00,$01,$00,$1c,$0c,$01,$00,$01,$00,$00,$01,$01,$01,$00,$01,$00,$01,$00,$01,$00,$01

	*= text
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"
	!scr "all work and no asm makes me no demo boy"

	!byte $ff
