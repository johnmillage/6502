;:ts=8
		CHIP	65C02
	;TmpStart = 38
;#define USING_02 1
;#include "INTRINS.H"
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
;#define HIGH  0xf0
;#define LOW   0x0f
;
; // LCD register bits
;#define LCD_E     0x80  // Enable
;#define LCD_R     0x40  // Read -write is 0
;#define LCD_RS    0x20  // register Select
;#define LCD_BUSY  0x08  // busy flag
;
;#define RAM_START 0x1000 
;#define COUNTER   0x1000 // 2 byte counter
;#define SHIFT     0x1002 // 1 byte shift counter
;#define MESSAGE   0x1004  //16 bytes
;#define SERIAL    0x1014  //1 byte
;#define ASKWORK   0x1015  //1 byte
;#define KEYCODE   0x1016  //1 byte
;#define LCDPTR    0x1017  //2 byte lcd stack pointer
;#define LCDSTACK  0x1019  //256 bytes lcd stack
;#define LCDSTEND  0x1119  //end of the lcd stack
;
;//check if lcd is ready
;unsigned char lcd_busy() {
	code
	xdef	_lcd_busy
	func
_lcd_busy:
	xref	~csav
	jsr	~csav
	db	0
	db	L2
	dw	L3
;     unsigned char busy = 0x08;
;    
;    *(unsigned char*)DDRA = 0xf7;  //set PORTA to high output
	lda	#8
	ldy	#255
	sta	(54),Y
	lda	#247
	sta	24579
;                                   // low input
;    *(unsigned char*)PORTA = LCD_R; // set Read
	lda	#64
	sta	24577
;    *(unsigned char*)PORTA = LCD_R|LCD_E; // set Read and E
	lda	#192
	sta	24577
;    busy = *(unsigned char*)PORTA; //read busy flag from PORTA
	lda	24577
	sta	(54),Y
;    *(unsigned char*)PORTA = LCD_R; // set Read and E
	lda	#64
	sta	24577
;    *(unsigned char*)PORTA = LCD_R|LCD_E; // set Read and E
	lda	#192
	sta	24577
;    
;    *(unsigned char*)PORTA = LCD_R; // set Read
	lda	#64
	sta	24577
;    *(char*)DDRA = 0xff;  //set PORTA output
	sty	24579
;    return busy&LCD_BUSY;
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	#8
	and	<72
	sta	<68
	txa
	sta	<69
	lda	<68
	sta	<56
	txa
	sta	<57
	rts
;}
L2	equ	0
L3	equ	-1
	ends
	efunc
;
;void send_lcd_instruction(unsigned char ins, unsigned char single)
;{
	code
	xdef	_send_lcd_instruction
	func
_send_lcd_instruction:
ins_0	set	9
single_0	set	11
	xref	~csav
	jsr	~csav
	db	4
	db	L4
	dw	L5
;    unsigned char send = ins&HIGH;
;     send = send>>4;
	lda	#240
	ldy	#9
	and	(52),Y
	ldy	#255
	sta	(54),Y
	lda	#4
	sta	<72
	stx	73
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~lsr
	jsr	~lsr
	lda	<64
	ldy	#255
	sta	(54),Y
;    *(unsigned char*)PORTA = send;
	lda	(54),Y
	sta	24577
;    *(unsigned char*)PORTA = send|LCD_E;
	lda	#128
	ora	(54),Y
	sta	24577
;    *(unsigned char*)PORTA = send;  //clear flags
	lda	(54),Y
	sta	24577
;    if (single == 0x00) {
	ldy	#11
	lda	(52),Y
	beq	L6
	jmp	L10001
L6:
;        send = ins&LOW;
	lda	#15
	ldy	#9
	and	(52),Y
	ldy	#255
	sta	(54),Y
;        *(unsigned char*)PORTA = send;
	lda	(54),Y
	sta	24577
;        *(unsigned char*)PORTA = send|LCD_E;
	lda	#128
	ora	(54),Y
	sta	24577
;        *(unsigned char*)PORTA = send;  //clear flags
	lda	(54),Y
	sta	24577
;    }
;    
;}
L10001:
	rts
L4	equ	0
L5	equ	-1
	ends
	efunc
;
;void send_lcd_char(unsigned char c) {
	code
	xdef	_send_lcd_char
	func
_send_lcd_char:
c_0	set	9
	xref	~csav
	jsr	~csav
	db	2
	db	L7
	dw	L8
;    unsigned char send = c&HIGH;
;    
;    send = send>>4;
	lda	#240
	ldy	#9
	and	(52),Y
	ldy	#255
	sta	(54),Y
	lda	#4
	sta	<72
	stx	73
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~lsr
	jsr	~lsr
	lda	<64
	ldy	#255
	sta	(54),Y
;    send = send|LCD_RS;
	lda	#32
	ora	(54),Y
	sta	(54),Y
;    *(unsigned char*)PORTA = send;
	lda	(54),Y
	sta	24577
;    *(unsigned char*)PORTA = send|LCD_E;
	lda	#128
	ora	(54),Y
	sta	24577
;    *(unsigned char*)PORTA = send;
	lda	(54),Y
	sta	24577
;
;    send = c&LOW;
	lda	#15
	ldy	#9
	and	(52),Y
	ldy	#255
	sta	(54),Y
;    send = send|LCD_RS;
	lda	#32
	ora	(54),Y
	sta	(54),Y
;    *(unsigned char*)PORTA = send;
	lda	(54),Y
	sta	24577
;    *(unsigned char*)PORTA = send|LCD_E;
	lda	#128
	ora	(54),Y
	sta	24577
;    *(unsigned char*)PORTA = send;
	lda	(54),Y
	sta	24577
;}
	rts
L7	equ	0
L8	equ	-1
	ends
	efunc
;
;unsigned char check_lcd_send();
;
;void lcd_print_char_async(unsigned char c)
;{
	code
	xdef	_lcd_print_char_async
	func
_lcd_print_char_async:
c_0	set	9
	xref	~csav
	jsr	~csav
	db	2
	db	L9
	dw	L10
;    unsigned int ptr;
;    ptr = *(unsigned int*)LCDPTR;
	lda	4119
	ldy	#254
	sta	(54),Y
	lda	4119+1
	iny
	sta	(54),Y
;    --ptr;
	clc
	tya
	dey
	adc	(54),Y
	sta	(54),Y
	lda	#255
	iny
	adc	(54),Y
	sta	(54),Y
;    *((unsigned char*)ptr) = c;
	dey
	lda	(54),Y
	sta	<72
	iny
	lda	(54),Y
	sta	<73
	ldy	#9
	lda	(52),Y
	sta	(72)
;    --ptr;
	clc
	lda	#255
	ldy	#254
	adc	(54),Y
	sta	(54),Y
	lda	#255
	iny
	adc	(54),Y
	sta	(54),Y
;    *(unsigned char*)ptr = 0x03;
	dey
	lda	(54),Y
	sta	<72
	iny
	lda	(54),Y
	sta	<73
	lda	#3
	sta	(72)
;    *(unsigned int*)LCDPTR = ptr;
	dey
	lda	(54),Y
	sta	4119
	iny
	lda	(54),Y
	sta	4119+1
;    check_lcd_send();
	jsr	_check_lcd_send
;}
	rts
L9	equ	0
L10	equ	-2
	ends
	efunc
;
;void lcd_send_instruction_async(unsigned char ins, unsigned char single)
;{
	code
	xdef	_lcd_send_instruction_async
	func
_lcd_send_instruction_async:
ins_0	set	9
single_0	set	11
	xref	~csav
	jsr	~csav
	db	4
	db	L11
	dw	L12
;    unsigned int ptr;
;    ptr = *(unsigned int*)LCDPTR;
	lda	4119
	ldy	#254
	sta	(54),Y
	lda	4119+1
	iny
	sta	(54),Y
;    --ptr;
	clc
	tya
	dey
	adc	(54),Y
	sta	(54),Y
	lda	#255
	iny
	adc	(54),Y
	sta	(54),Y
;    *(unsigned char*)ptr = ins;
	dey
	lda	(54),Y
	sta	<72
	iny
	lda	(54),Y
	sta	<73
	ldy	#9
	lda	(52),Y
	sta	(72)
;    --ptr;
	clc
	lda	#255
	ldy	#254
	adc	(54),Y
	sta	(54),Y
	lda	#255
	iny
	adc	(54),Y
	sta	(54),Y
;    *(unsigned char*)ptr = single;
	dey
	lda	(54),Y
	sta	<72
	iny
	lda	(54),Y
	sta	<73
	ldy	#11
	lda	(52),Y
	sta	(72)
;    *(unsigned int*)LCDPTR = ptr;
	ldy	#254
	lda	(54),Y
	sta	4119
	iny
	lda	(54),Y
	sta	4119+1
;    check_lcd_send();
	jsr	_check_lcd_send
;}
	rts
L11	equ	0
L12	equ	-2
	ends
	efunc
;
;unsigned char check_lcd_send() {
	code
	xdef	_check_lcd_send
	func
_check_lcd_send:
	xref	~csav
	jsr	~csav
	db	0
	db	L13
	dw	L14
;    unsigned char type;
;    unsigned char ins;
;    unsigned int ptr;
;    if (*(unsigned int*)LCDPTR == LCDSTEND) {
	lda	4119
	cmp	#25
	bne	L10003
	lda	4119+1
	cmp	#17
L10003:
	beq	L15
	jmp	L10002
L15:
;        return 0x00;  //nothing to do
	stx	<56
	stx	<57
	rts
;    }
;    if(!lcd_busy()) {
L10002:
	jsr	_lcd_busy
	lda	<56
	beq	L16
	jmp	L10004
L16:
;        ptr = *(unsigned int*)LCDPTR;
	lda	4119
	ldy	#252
	sta	(54),Y
	lda	4119+1
	iny
	sta	(54),Y
;        type = *(unsigned char*)ptr;
	dey
	lda	(54),Y
	sta	<72
	iny
	lda	(54),Y
	sta	<73
	lda	(72)
	ldy	#255
	sta	(54),Y
;        ++ptr;
	clc
	lda	#1
	ldy	#252
	adc	(54),Y
	sta	(54),Y
	txa
	iny
	adc	(54),Y
	sta	(54),Y
;        ins = *(unsigned char*)ptr;
	dey
	lda	(54),Y
	sta	<72
	iny
	lda	(54),Y
	sta	<73
	lda	(72)
	iny
	sta	(54),Y
;        ++ptr;
	clc
	lda	#1
	ldy	#252
	adc	(54),Y
	sta	(54),Y
	txa
	iny
	adc	(54),Y
	sta	(54),Y
;        *(unsigned int*)LCDPTR = ptr;
	dey
	lda	(54),Y
	sta	4119
	iny
	lda	(54),Y
	sta	4119+1
;        if(type == 0x01) {
	ldy	#255
	lda	(54),Y
	cmp	#1
	beq	L17
	jmp	L10005
L17:
;            send_lcd_instruction(ins, 0x00);
	phx
	phx
	txa
	pha
	ldy	#254
	lda	(54),Y
	pha
	jsr	_send_lcd_instruction
;        } else if(type == 0x02) {
	jmp	L10006
L10005:
	ldy	#255
	lda	(54),Y
	cmp	#2
	beq	L18
	jmp	L10007
L18:
;            send_lcd_instruction(ins, 0x01);
	phx
	lda	#1
	pha
	txa
	pha
	ldy	#254
	lda	(54),Y
	pha
	jsr	_send_lcd_instruction
;        } else {
	jmp	L10008
L10007:
;            send_lcd_char(ins);
	txa
	pha
	ldy	#254
	lda	(54),Y
	pha
	jsr	_send_lcd_char
;        }
L10008:
L10006:
;        return 0x01;  //sent
	lda	#1
	sta	<56
	stx	<57
	rts
;    }
;   return 0x02;  //not ready
L10004:
	lda	#2
	sta	<56
	stx	<57
	rts
;}
L13	equ	0
L14	equ	-4
	ends
	efunc
;
;void print_byte(unsigned char b) {
	code
	xdef	_print_byte
	func
_print_byte:
b_0	set	9
	xref	~csav
	jsr	~csav
	db	2
	db	L19
	dw	L20
;    unsigned char i = 0;
;    for(i; i < 0x08; i++) {
	ldy	#255
	sta	(54),Y
	jmp	L10010
L10009:
	clc
	lda	#1
	ldy	#255
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
L10010:
	ldy	#255
	lda	(54),Y
	cmp	#8
	bcc	L21
	jmp	L10011
L21:
;        if (b&0x80) {
	ldy	#9
	lda	(52),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#128
	bne	L22
	jmp	L10012
L22:
;            lcd_print_char_async('1');
	phx
	lda	#49
	pha
	jsr	_lcd_print_char_async
;        } else {
	jmp	L10013
L10012:
;            lcd_print_char_async('0');
	phx
	lda	#48
	pha
	jsr	_lcd_print_char_async
;        }
L10013:
;        b = b << 1;
	lda	#1
	sta	<72
	stx	73
	ldy	#9
	lda	(52),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#9
	sta	(52),Y
;    }
	jmp	L10009
L10011:
;}
	rts
L19	equ	0
L20	equ	-1
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
	db	L23
	dw	L24
;    while(*str != 0) {
L10014:
	ldy	#9
	lda	(52),Y
	sta	<72
	iny
	lda	(52),Y
	sta	<73
	lda	(72)
	bne	L25
	jmp	L10015
L25:
;        lcd_print_char_async(*str);
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
	jsr	_lcd_print_char_async
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
	jmp	L10014
L10015:
;}
	rts
L23	equ	0
L24	equ	0
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
	db	L26
	dw	L27
;    unsigned char last_shift;
;    unsigned char last_counter;
;    *(unsigned char*)IERG = 0x92;  //set CA1 AND CB1 Interrupt enable
	lda	#146
	sta	24590
;    *(unsigned char*)PCRG = 0x00;  //set CA's to active edge low
	stx	24588
;    
;    *(unsigned char*)ACRG = 0x0c; //set shift in ACRG
	lda	#12
	sta	24587
;    *(char*)DDRA = 0xef;  //set PORTA output - except last pin of first nibble
	lda	#239
	sta	24579
;    *(char*)DDRB = 0x00;  //set PORTB input
	stx	24578
;    *(unsigned char*)SHIFT = 0x00;
	stx	4098
;    *(unsigned char*)KEYCODE = 0x00;
	stx	4118
;    *(unsigned int*)COUNTER = 0;
	stx	4096
	stx	4096+1
;    last_counter = 0;
	txa
	ldy	#254
	sta	(54),Y
;    last_shift = 0x00;
	iny
	sta	(54),Y
;    *(unsigned int*)LCDPTR = LCDSTEND;
	lda	#25
	sta	4119
	lda	#17
	sta	4119+1
;
;    lcd_send_instruction_async(0x20, 0x01);  //set 4 bit mode
	phx
	lda	#1
	pha
	phx
	lda	#32
	pha
	jsr	_lcd_send_instruction_async
;    lcd_send_instruction_async(0x28, 0x00);  //set 4 bit mode, 2 lines
	phx
	phx
	phx
	lda	#40
	pha
	jsr	_lcd_send_instruction_async
;    lcd_send_instruction_async(0x0e, 0x00);  // turn on display
	phx
	phx
	phx
	lda	#14
	pha
	jsr	_lcd_send_instruction_async
;    lcd_send_instruction_async(0x06, 0x00);  //increment and shift cursor
	phx
	phx
	phx
	lda	#6
	pha
	jsr	_lcd_send_instruction_async
;
;    //flush all the sends
;    while(check_lcd_send()) {}
L10016:
	jsr	_check_lcd_send
	lda	<56
	bne	L28
	jmp	L10017
L28:
	jmp	L10016
L10017:
;
;    //done with startup
;   
;    while(1) {
L10018:
;        //see if we can drain the lcd stack
;        check_lcd_send();
	jsr	_check_lcd_send
;        if(*(unsigned char*)SHIFT != last_shift) {
	lda	4098
	ldy	#255
	cmp	(54),Y
	bne	L29
	jmp	L10020
L29:
;            lcd_send_instruction_async(0x02, 0);  //set display to home
	phx
	phx
	phx
	lda	#2
	pha
	jsr	_lcd_send_instruction_async
;            print_string("SHIFT ");
	lda	#>L1
	pha
	lda	#<L1
	pha
	jsr	_print_string
;            lcd_print_char_async('0' + *(unsigned char*)SHIFT);
	lda	4098
	sta	<72
	txa
	sta	<73
	clc
	lda	#48
	adc	<72
	sta	<68
	txa
	adc	<73
	sta	<69
	txa
	pha
	lda	<68
	pha
	jsr	_lcd_print_char_async
;            lcd_print_char_async(' ');
	phx
	lda	#32
	pha
	jsr	_lcd_print_char_async
;            print_byte(*(unsigned char*)SHRG);
	pha
	lda	24586
	pha
	jsr	_print_byte
;            if(*(unsigned char*)SHIFT == 0x08) {
	lda	4098
	cmp	#8
	beq	L30
	jmp	L10021
L30:
;                *(unsigned char*)SHIFT = 0x00;
	stx	4098
;            }
;        }
L10021:
;        if(*(unsigned char*)COUNTER != last_counter) {
L10020:
	lda	4096
	ldy	#254
	cmp	(54),Y
	bne	L31
	jmp	L10022
L31:
;            lcd_send_instruction_async(0xc0, 0);  //set to second line
	phx
	phx
	phx
	lda	#192
	pha
	jsr	_lcd_send_instruction_async
;            print_string("COUNTER ");
	lda	#>L1+7
	pha
	lda	#<L1+7
	pha
	jsr	_print_string
;            print_byte(*(unsigned char*)COUNTER);
	pha
	lda	4096
	pha
	jsr	_print_byte
;        }
;    }
L10022:
	jmp	L10018
;}
L26	equ	0
L27	equ	-2
	ends
	efunc
	data
L1:
	db	$53,$48,$49,$46,$54,$20,$00,$43,$4F,$55,$4E,$54,$45,$52,$20
	db	$00
	ends
;
	end
