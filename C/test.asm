;:ts=8
		CHIP	65C02
	;TmpStart = 58
	code
	xdef	_f
	func
_f:
	xref	~csav
	jsr	~csav
	db	0
	db	L2
	dw	L3
	ldy	#254
	sta	(86),Y
	iny
	sta	(86),Y
	clc
	lda	#1
	dey
	adc	(86),Y
	sta	(86),Y
	txa
	iny
	adc	(86),Y
	sta	(86),Y
	rts
L2	equ	0
L3	equ	-2
	ends
	efunc
	code
	xdef	_main
	func
_main:
	xref	~csav
	jsr	~csav
	db	0
	db	L4
	dw	L5
	jsr	_f
	rts
L4	equ	0
L5	equ	0
	ends
	efunc
	end
