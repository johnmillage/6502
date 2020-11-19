;:ts=8
		CHIP	65C02
	;TmpStart = 38
;#define USING_02 1
; // W65C22S registers 
;#define PORTB 0x6000  // in/out PortB
;#define PORTA 0x6001  // in/out PortA
;#define DDRB  0x6002  // Data Direction PortB
;#define DDRA  0x6003  // Data Direction PortA
;#define T1CL  0x6004  // Timer 1 low order counter
;#define TICH  0x6005  // Timer 1 high order counter
;#define T1LL  0x6006  // Timer 1 low order latch
;#define T1LH  0x6007  // Timer 1 high order latch
;#define T2CL  0x6008  // Timer 2 low order counter
;#define T2CH  0x6009  // Timer 2 high order counter
;#define SHRG  0x600a  // Shift register
;#define ACRG  0x600b  // Aux control register
;#define PCRG  0x600c  // Peripheral register
;#define IFRG  0x600d  // Interrupt flag register
;#define IERG  0x600e  // Interrupt Enable register
;#define ORAH  0x600f  // in/out PortA w/o handshake
;
; // LCD register bits
;#define LCD_E     0x80  // Enable
;#define LCD_RW    0x40  // Read/Write
;#define LCD_RS    0x20  // Select
;
;void lcd_wait() {
	code
	xdef	_lcd_wait
	func
_lcd_wait:
	xref	~csav
	jsr	~csav
	db	0
	db	L2
	dw	L3
;    unsigned char busy = 0x80;
;    
;    *(unsigned char*)DDRB = 0x00;  //set PORTB input
	lda	#128
	ldy	#255
	sta	(54),Y
	stx	24578
;    
;    while(busy & 0x80){
L10001:
	ldy	#255
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#128
	bne	L4
	jmp	L10002
L4:
;        *(unsigned char*)PORTA = LCD_RW; // set RW
	lda	#64
	sta	24577
;        *(unsigned char*)PORTA = LCD_RW|LCD_E; // set RW and E
	lda	#192
	sta	24577
;        busy = *(unsigned char*)PORTB; //read busy flag from port b
	lda	24576
	ldy	#255
	sta	(54),Y
;    }
	jmp	L10001
L10002:
;    *(unsigned char*)PORTA = LCD_RW; // set RW
	lda	#64
	sta	24577
;    *(char*)DDRB = 0xff;  //set PORTB output
	lda	#255
	sta	24578
;}
	rts
L2	equ	0
L3	equ	-1
	ends
	efunc
;
;void lcd_instruction(unsigned char ins)
;{
	code
	xdef	_lcd_instruction
	func
_lcd_instruction:
ins_0	set	9
	xref	~csav
	jsr	~csav
	db	2
	db	L5
	dw	L6
;    lcd_wait();
	jsr	_lcd_wait
;    *(unsigned char*)PORTB = ins;  // send instruction
	ldy	#9
	lda	(52),Y
	sta	24576
;    *(unsigned char*)PORTA = 0x00;  // clear flags
	stx	24577
;    *(unsigned char*)PORTA = LCD_E; // set enabled flag
	lda	#128
	sta	24577
;    *(unsigned char*)PORTA = 0x00; //clear flags
	stx	24577
;}
	rts
L5	equ	0
L6	equ	0
	ends
	efunc
;
;void print_char(unsigned char c) {
	code
	xdef	_print_char
	func
_print_char:
c_0	set	9
	xref	~csav
	jsr	~csav
	db	2
	db	L7
	dw	L8
;    lcd_wait();
	jsr	_lcd_wait
;    *(unsigned char*)PORTB = c;
	ldy	#9
	lda	(52),Y
	sta	24576
;    *(unsigned char*)PORTA = LCD_RS;
	lda	#32
	sta	24577
;    *(unsigned char*)PORTA = LCD_RS|LCD_E;
	lda	#160
	sta	24577
;    *(unsigned char*)PORTA = LCD_RS;
	lda	#32
	sta	24577
;}
	rts
L7	equ	0
L8	equ	0
	ends
	efunc
;
;void print_string(const unsigned char * str)
;{
	code
	xdef	_print_string
	func
_print_string:
str_0	set	9
	xref	~csav
	jsr	~csav
	db	2
	db	L9
	dw	L10
;    while(*str != 0) {
L10003:
	ldy	#9
	lda	(52),Y
	sta	<72
	iny
	lda	(52),Y
	sta	<73
	lda	(72)
	bne	L11
	jmp	L10004
L11:
;        print_char(*str);
	ldy	#9
	lda	(52),Y
	sta	<72
	iny
	lda	(52),Y
	sta	<73
	txa
	pha
	lda	(72)
	pha
	jsr	_print_char
;        ++str;
	clc
	tya
	ldy	#9
	adc	(52),Y
	sta	(52),Y
	txa
	iny
	adc	(52),Y
	sta	(52),Y
;    }
	jmp	L10003
L10004:
;}
	rts
L9	equ	0
L10	equ	0
	ends
	efunc
;
;void main() {
	code
	xdef	_main
	func
_main:
	xref	~csav
	jsr	~csav
	db	0
	db	L12
	dw	L13
;    *(char*)DDRB = 0xff;  //set PORTB output
	lda	#255
	sta	24578
;    *(char*)DDRA = 0xe0;  //set first 3 pins of PORTA output
	lda	#224
	sta	24579
;
;    lcd_instruction(0x38);  //set 8 bit mode, 2 lines
	phx
	lda	#56
	pha
	jsr	_lcd_instruction
;    lcd_instruction(0x0e);  // turn on display
	phx
	lda	#14
	pha
	jsr	_lcd_instruction
;    lcd_instruction(0x06);  //increment and shift cursor
	phx
	lda	#6
	pha
	jsr	_lcd_instruction
;
;    print_string("HEY JOHN");
	lda	#>L1
	pha
	lda	#<L1
	pha
	jsr	_print_string
;    while(1) {}
L10005:
	jmp	L10005
;}
L12	equ	0
L13	equ	0
	ends
	efunc
	data
L1:
	db	$48,$45,$59,$20,$4A,$4F,$48,$4E,$00
	ends
;
	end
