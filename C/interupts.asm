;:ts=8
		CHIP	65C02
	;TmpStart = 38
;
;#include "stdlib.h"
;#include "INTRINS.H"
;
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
;#define RAM_START 0x1000 
;#define COUNTER   0x1000  //2 bytes
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
;void my_itoa(int value, unsigned char* str) {
	code
	xdef	_my_itoa
	func
_my_itoa:
value_0	set	9
str_0	set	11
	xref	~csav
	jsr	~csav
	db	4
	db	L12
	dw	L13
;    unsigned short idx = 0;
;    //if (value == 0) {
;    //    str[0] = '0' + abs(value);
;    //    str[1] = 0x00;
;    //    return;
;    //}
;    do {
	ldy	#254
	sta	(54),Y
	iny
	sta	(54),Y
L10007:
;        int quot = value / 10;
;        int rem = value % 10;
;        str[idx] = '0' + rem;
	lda	#10
	sta	<72
	stx	<73
	ldy	#9
	lda	(52),Y
	sta	<68
	iny
	lda	(52),Y
	sta	<69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~div
	jsr	~div
	lda	<64
	ldy	#252
	sta	(54),Y
	lda	<65
	iny
	sta	(54),Y
	lda	#10
	sta	<72
	stx	<73
	ldy	#9
	lda	(52),Y
	sta	<68
	iny
	lda	(52),Y
	sta	<69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~mod
	jsr	~mod
	lda	<64
	ldy	#250
	sta	(54),Y
	lda	<65
	iny
	sta	(54),Y
	clc
	ldy	#11
	lda	(52),Y
	ldy	#254
	adc	(54),Y
	sta	<72
	ldy	#12
	lda	(52),Y
	ldy	#255
	adc	(54),Y
	sta	<73
	clc
	lda	#48
	ldy	#250
	adc	(54),Y
	sta	<68
	txa
	iny
	adc	(54),Y
	sta	<69
	lda	<68
	sta	(72)
;        ++idx;
	clc
	lda	#1
	ldy	#254
	adc	(54),Y
	sta	(54),Y
	txa
	iny
	adc	(54),Y
	sta	(54),Y
;        value = quot;
	ldy	#252
	lda	(54),Y
	ldy	#9
	sta	(52),Y
	ldy	#253
	lda	(54),Y
	ldy	#10
	sta	(52),Y
;    }while(value != 0);
L10005:
	ldy	#9
	lda	(52),Y
	iny
	ora	(52),Y
	beq	L14
	jmp	L10007
L14:
L10006:
;    str[idx] = 0x00;
	clc
	ldy	#11
	lda	(52),Y
	ldy	#254
	adc	(54),Y
	sta	<72
	ldy	#12
	lda	(52),Y
	ldy	#255
	adc	(54),Y
	sta	<73
	txa
	sta	(72)
;}
	rts
L12	equ	0
L13	equ	-6
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
	db	L15
	dw	L16
;    unsigned char message[16];
;    *(unsigned char*)IERG = 0x82;  //set CA1 Interrupt enable
	lda	#130
	sta	24590
;    *(unsigned char*)PCRG = 0x00;  //set CA1 to active edge low
	stx	24588
;    *(unsigned char*)DDRB = 0xff;  //set PORTB output
	lda	#255
	sta	24578
;    *(unsigned char*)DDRA = 0xe0;  //set first 3 pins of PORTA output
	lda	#224
	sta	24579
;    *(unsigned int*)COUNTER = 1;
	sty	4096
	stx	4096+1
;
;    lcd_instruction(0x38);  //set 8 bit mode, 2 lines
	phx
	lda	#56
	pha
	jsr	_lcd_instruction
;    lcd_instruction(0x0e);  //turn on display
	phx
	lda	#14
	pha
	jsr	_lcd_instruction
;    lcd_instruction(0x06);  //increment and shift cursor
	phx
	lda	#6
	pha
	jsr	_lcd_instruction
;    lcd_instruction(0x01);  //clear the screen
	phx
	phy
	jsr	_lcd_instruction
;
;    while(1) {
L10008:
;        lcd_instruction(0x02);  //set display to home
	phx
	lda	#2
	pha
	jsr	_lcd_instruction
;        SEI
	sei
;        my_itoa(*(int*)COUNTER, message);
	clc
	lda	#240
	adc	54
	sta	<72
	txa
	adc	55
	sta	<73
	lda	<73
	pha
	lda	<72
	pha
	lda	4096+1
	pha
	lda	4096
	pha
	jsr	_my_itoa
;        print_string(message);
	clc
	lda	#240
	adc	54
	sta	<72
	txa
	adc	55
	sta	<73
	lda	<73
	pha
	lda	<72
	pha
	jsr	_print_string
;        CLI
	cli
;
;
;    }
	jmp	L10008
;}
L15	equ	0
L16	equ	-16
	ends
	efunc
;
	end
