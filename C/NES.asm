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
;#define T1CH  0x6005  // Timer 1 high order counter
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
;#define QUESTART  0x1017  //1 byte lcd queue start index
;#define QUEEND    0x1018  //1 byte lcd queue end index
;#define LCDQUEUE  0x1019  //256 bytes lcd queue
;#define LCDQUEEND 0x1119  //end of the lcd stack
;#define TIMER1    0x111a  //timer 1 fired
;#define TIMER2    0x111b  //timer 2 fired
;#define TM1VAL    0x111c  //2 bytes (int) - timer 1 value
;#define TM1HIGH   0x111d  //high byte of time 1 value
;#define TM2VAL    0x111e  //2 bytes (int) - timer 2 value
;#define TM2HIGH   0x111f  //high byte of time 2 value
;
;void set_timer_1(unsigned int tm) {
	code
	xdef	_set_timer_1
	func
_set_timer_1:
tm_0	set	9
	xref	~csav
	jsr	~csav
	db	2
	db	L2
	dw	L3
;    *(unsigned int*)TM1VAL = tm;
	ldy	#9
	lda	(52),Y
	sta	4380
	iny
	lda	(52),Y
	sta	4380+1
;    *(unsigned int*)T1CL = *(unsigned char*)TM1VAL;
	lda	4380
	sta	24580
	txa
	sta	24580+1
;    *(unsigned int*)T1CH = *(unsigned char*)TM1HIGH;
	lda	4381
	sta	24581
	txa
	sta	24581+1
;}
	rts
L2	equ	0
L3	equ	0
	ends
	efunc
;
;void set_timer_2(unsigned int tm) {
	code
	xdef	_set_timer_2
	func
_set_timer_2:
tm_0	set	9
	xref	~csav
	jsr	~csav
	db	2
	db	L4
	dw	L5
;    *(unsigned int*)TM2VAL = tm;
	ldy	#9
	lda	(52),Y
	sta	4382
	iny
	lda	(52),Y
	sta	4382+1
;    *(unsigned int*)T2CL = *(unsigned char*)TM2VAL;
	lda	4382
	sta	24584
	txa
	sta	24584+1
;    *(unsigned int*)T2CH = *(unsigned char*)TM2HIGH;
	lda	4383
	sta	24585
	txa
	sta	24585+1
;}
	rts
L4	equ	0
L5	equ	0
	ends
	efunc
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
	db	L6
	dw	L7
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
L6	equ	0
L7	equ	-1
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
	db	L8
	dw	L9
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
	beq	L10
	jmp	L10001
L10:
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
L8	equ	0
L9	equ	-1
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
	db	L11
	dw	L12
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
L11	equ	0
L12	equ	-1
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
	db	L13
	dw	L14
;    unsigned int ptr;
;    unsigned char idx;
;    ptr = LCDQUEUE;
	lda	#25
	ldy	#254
	sta	(54),Y
	lda	#16
	iny
	sta	(54),Y
;    idx = *(unsigned char*)QUEEND;
	lda	4120
	ldy	#253
	sta	(54),Y
;    ptr += idx;
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	clc
	lda	<72
	iny
	adc	(54),Y
	sta	(54),Y
	lda	<73
	iny
	adc	(54),Y
	sta	(54),Y
;    *(unsigned char*)ptr = c;
	dey
	lda	(54),Y
	sta	<72
	iny
	lda	(54),Y
	sta	<73
	ldy	#9
	lda	(52),Y
	sta	(72)
;    ++ptr;
	clc
	lda	#1
	ldy	#254
	adc	(54),Y
	sta	(54),Y
	txa
	iny
	adc	(54),Y
	sta	(54),Y
;    ++idx;
	clc
	lda	#1
	ldy	#253
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
;    *(unsigned char*)ptr = 0x02;
	iny
	lda	(54),Y
	sta	<72
	iny
	lda	(54),Y
	sta	<73
	lda	#2
	sta	(72)
;    if(ptr == LCDQUEEND) {
	dey
	lda	(54),Y
	cmp	#25
	bne	L10003
	ldy	#255
	lda	(54),Y
	cmp	#17
L10003:
	beq	L15
	jmp	L10002
L15:
;        idx = 0;
	txa
	ldy	#253
	sta	(54),Y
;    } else {
	jmp	L10004
L10002:
;        ++idx;
	clc
	lda	#1
	ldy	#253
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
;    }
L10004:
;    *(unsigned char*)QUEEND = idx;
	ldy	#253
	lda	(54),Y
	sta	4120
;    check_lcd_send();
	jsr	_check_lcd_send
;}
	rts
L13	equ	0
L14	equ	-3
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
	db	L16
	dw	L17
;    unsigned int ptr;
;    unsigned char idx;
;    ptr = LCDQUEUE;
	lda	#25
	ldy	#254
	sta	(54),Y
	lda	#16
	iny
	sta	(54),Y
;    idx = *(unsigned char*)QUEEND;
	lda	4120
	ldy	#253
	sta	(54),Y
;    ptr += idx;
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	clc
	lda	<72
	iny
	adc	(54),Y
	sta	(54),Y
	lda	<73
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
;    ++ptr;
	clc
	lda	#1
	ldy	#254
	adc	(54),Y
	sta	(54),Y
	txa
	iny
	adc	(54),Y
	sta	(54),Y
;    ++idx;
	clc
	lda	#1
	ldy	#253
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
;    *(unsigned char*)ptr = single;
	iny
	lda	(54),Y
	sta	<72
	iny
	lda	(54),Y
	sta	<73
	ldy	#11
	lda	(52),Y
	sta	(72)
;    if(ptr == LCDQUEEND) {
	ldy	#254
	lda	(54),Y
	cmp	#25
	bne	L10006
	ldy	#255
	lda	(54),Y
	cmp	#17
L10006:
	beq	L18
	jmp	L10005
L18:
;        idx = 0;
	txa
	ldy	#253
	sta	(54),Y
;    } else {
	jmp	L10007
L10005:
;        ++idx;
	clc
	lda	#1
	ldy	#253
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
;    }
L10007:
;    *(unsigned char*)QUEEND = idx;
	ldy	#253
	lda	(54),Y
	sta	4120
;    check_lcd_send();
	jsr	_check_lcd_send
;}
	rts
L16	equ	0
L17	equ	-3
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
	db	L19
	dw	L20
;    unsigned char type;
;    unsigned char ins;
;    unsigned int ptr;
;    unsigned char idx = *(unsigned char*)QUESTART;
;    if (idx == *(unsigned char*)QUEEND) {
	lda	4119
	ldy	#251
	sta	(54),Y
	lda	(54),Y
	cmp	4120
	beq	L21
	jmp	L10008
L21:
;        return 0x00;  //nothing to do
	stx	<56
	stx	<57
	rts
;    }
;    if(!lcd_busy()) {
L10008:
	jsr	_lcd_busy
	lda	<56
	beq	L22
	jmp	L10009
L22:
;        ptr = LCDQUEUE;
	lda	#25
	ldy	#252
	sta	(54),Y
	lda	#16
	iny
	sta	(54),Y
;        ptr += idx;
	ldy	#251
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	clc
	lda	<72
	iny
	adc	(54),Y
	sta	(54),Y
	lda	<73
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
;        ++idx;
	clc
	lda	#1
	ldy	#251
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
;        type = *(unsigned char*)ptr;
	iny
	lda	(54),Y
	sta	<72
	iny
	lda	(54),Y
	sta	<73
	lda	(72)
	ldy	#255
	sta	(54),Y
;        if (ptr == LCDQUEEND){
	ldy	#252
	lda	(54),Y
	cmp	#25
	bne	L10011
	ldy	#253
	lda	(54),Y
	cmp	#17
L10011:
	beq	L23
	jmp	L10010
L23:
;             idx = 0;
	txa
	ldy	#251
	sta	(54),Y
;        } else {
	jmp	L10012
L10010:
;            ++idx;
	clc
	lda	#1
	ldy	#251
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
;        }
L10012:
;        *(unsigned char*)QUESTART = idx;
	ldy	#251
	lda	(54),Y
	sta	4119
;        if(type == 0x02) {
	ldy	#255
	lda	(54),Y
	cmp	#2
	beq	L24
	jmp	L10013
L24:
;            send_lcd_char(ins);
	txa
	pha
	ldy	#254
	lda	(54),Y
	pha
	jsr	_send_lcd_char
;        } else {
	jmp	L10014
L10013:
;            send_lcd_instruction(ins, type);
	txa
	pha
	ldy	#255
	lda	(54),Y
	pha
	txa
	pha
	dey
	lda	(54),Y
	pha
	jsr	_send_lcd_instruction
;        }
L10014:
;        return 0x01;  //sent
	lda	#1
	sta	<56
	stx	<57
	rts
;    }
;   return 0x02;  //not ready
L10009:
	lda	#2
	sta	<56
	stx	<57
	rts
;}
L19	equ	0
L20	equ	-5
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
	db	L25
	dw	L26
;    unsigned char i = b&HIGH;
;    
;    i = i>>4;
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
;    if (i < 0x0a) {
	lda	(54),Y
	cmp	#10
	bcc	L27
	jmp	L10015
L27:
;        lcd_print_char_async('0' + i);
	ldy	#255
	lda	(54),Y
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
;    } else {
	jmp	L10016
L10015:
;        i-=0x0a;
	ldy	#255
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	clc
	lda	#246
	adc	<72
	sta	<68
	tya
	adc	<73
	sta	<69
	lda	<68
	sta	(54),Y
;        lcd_print_char_async('a' + i);
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	clc
	lda	#97
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
;    }
L10016:
;    i = b&LOW;
	lda	#15
	ldy	#9
	and	(52),Y
	ldy	#255
	sta	(54),Y
;     if (i < 0x0a) {
	lda	(54),Y
	cmp	#10
	bcc	L28
	jmp	L10017
L28:
;        lcd_print_char_async('0' + i);
	ldy	#255
	lda	(54),Y
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
;    } else {
	jmp	L10018
L10017:
;        i-=0x0a;
	ldy	#255
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	clc
	lda	#246
	adc	<72
	sta	<68
	tya
	adc	<73
	sta	<69
	lda	<68
	sta	(54),Y
;        lcd_print_char_async('a' + i);
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	clc
	lda	#97
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
;    }
L10018:
;}
	rts
L25	equ	0
L26	equ	-1
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
	db	L29
	dw	L30
;    while(*str != 0) {
L10019:
	ldy	#9
	lda	(52),Y
	sta	<72
	iny
	lda	(52),Y
	sta	<73
	lda	(72)
	bne	L31
	jmp	L10020
L31:
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
	jmp	L10019
L10020:
;}
	rts
L29	equ	0
L30	equ	0
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
	db	L32
	dw	L33
;    unsigned char last_shift;
;    unsigned char last_counter;
;    unsigned char nes_controller1;
;    unsigned char nes_controller2;
;    *(unsigned char*)IERG = 0xf2;  //set CA1 AND CB1 Interrupt enable
	lda	#242
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
;    *(char*)DDRB = 0x0c;  //set PORTB output on last 2 pins of first nibble, others input
	lda	#12
	sta	24578
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
;    nes_controller1 = 0x00;
	ldy	#253
	sta	(54),Y
;    nes_controller2 = 0x00;
	dey
	sta	(54),Y
;    *(unsigned int*)QUESTART = 0x00;
	stx	4119
	stx	4119+1
;    *(unsigned int*)QUEEND = 0x00;
	stx	4120
	stx	4120+1
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
;    //flush all the sends
;    while(check_lcd_send()) {}
L10021:
	jsr	_check_lcd_send
	lda	<56
	bne	L34
	jmp	L10022
L34:
	jmp	L10021
L10022:
;
;    //done with startup
;    set_timer_1(0x411b);  //60Hz, 16.67ms
	lda	#65
	pha
	lda	#27
	pha
	jsr	_set_timer_1
;    while(1) {
L10023:
;        //see if we can drain the lcd stack
;        check_lcd_send();
	jsr	_check_lcd_send
;        if(*(unsigned char*)SHIFT != last_shift) {
	lda	4098
	ldy	#255
	cmp	(54),Y
	bne	L35
	jmp	L10025
L35:
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
;            if(*(unsigned char*)SHIFT >= 0x08) {
	lda	4098
	cmp	#8
	bcs	L36
	jmp	L10026
L36:
;                *(unsigned char*)SHIFT = 0x00;
	stx	4098
;            }
;            last_shift = *(unsigned char*)SHIFT;
L10026:
	lda	4098
	ldy	#255
	sta	(54),Y
;
;        }
;        if(*(unsigned char*)COUNTER != last_counter) {
L10025:
	lda	4096
	ldy	#254
	cmp	(54),Y
	bne	L37
	jmp	L10027
L37:
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
;        if(*(unsigned char*)TIMER1){
L10027:
	lda	4378
	bne	L38
	jmp	L10028
L38:
;            unsigned char nes_current1;
;            unsigned char nes_current2;
;            unsigned char nes_read;
;            unsigned char idx;
;            *(unsigned char*)PORTB = 0x08; //NES set latch high
	lda	#8
	sta	24576
;            *(unsigned char*)TIMER1 = 0x00;
	stx	4378
;            {asm nop;}  //give latch some time
	nop
;            {asm nop;}
	nop
;            {asm nop;}
	nop
;            *(unsigned char*)PORTB = 0x00; //NES set latch low
	stx	24576
;
;            //now read first bits
;            nes_read = *(unsigned char*)PORTB;
	lda	24576
	ldy	#249
	sta	(54),Y
;            nes_current1 = nes_current1<<1;
	lda	#1
	sta	<72
	stx	73
	ldy	#251
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#251
	sta	(54),Y
;            if (nes_read&0x01) {
	ldy	#249
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L39
	jmp	L10029
L39:
;                nes_current1 = nes_current1|0x01;
	lda	#1
	ldy	#251
	ora	(54),Y
	sta	(54),Y
;            }
;            nes_read = nes_read>>1;
L10029:
	lda	#1
	sta	<72
	stx	73
	ldy	#249
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~lsr
	jsr	~lsr
	lda	<64
	ldy	#249
	sta	(54),Y
;            nes_current2 = nes_current2<<1;
	lda	#1
	sta	<72
	stx	73
	iny
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#250
	sta	(54),Y
;            if(nes_read&0x01) {
	dey
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L40
	jmp	L10030
L40:
;                nes_current2 = nes_current2|0x01;
	lda	#1
	ldy	#250
	ora	(54),Y
	sta	(54),Y
;            }
;            //pulse the clock
;            *(unsigned char*)PORTB = 0x04; //NES set clock high
L10030:
	lda	#4
	sta	24576
;            {asm nop;}
	nop
;            {asm nop;}
	nop
;            {asm nop;}
	nop
;            *(unsigned char*)PORTB = 0x00; //NES set clock low
	stx	24576
;
;            for(idx = 0x00; idx < 0x07;++idx){
	txa
	ldy	#248
	sta	(54),Y
	jmp	L10032
L10031:
	clc
	lda	#1
	ldy	#248
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
L10032:
	ldy	#248
	lda	(54),Y
	cmp	#7
	bcc	L41
	jmp	L10033
L41:
;                nes_read = *(unsigned char*)PORTB;
	lda	24576
	ldy	#249
	sta	(54),Y
;                nes_current1 = nes_current1<<1;
	lda	#1
	sta	<72
	stx	73
	ldy	#251
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#251
	sta	(54),Y
;                if (nes_read&0x01) {
	ldy	#249
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L42
	jmp	L10034
L42:
;                    nes_current1 = nes_current1|0x01;
	lda	#1
	ldy	#251
	ora	(54),Y
	sta	(54),Y
;                }
;                nes_read = nes_read>>1;
L10034:
	lda	#1
	sta	<72
	stx	73
	ldy	#249
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~lsr
	jsr	~lsr
	lda	<64
	ldy	#249
	sta	(54),Y
;                nes_current2 = nes_current2<<1;
	lda	#1
	sta	<72
	stx	73
	iny
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#250
	sta	(54),Y
;                if(nes_read&0x01) {
	dey
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L43
	jmp	L10035
L43:
;                    nes_current2 = nes_current2|0x01;
	lda	#1
	ldy	#250
	ora	(54),Y
	sta	(54),Y
;                }
;                //pulse the clock again
;                *(unsigned char*)PORTB = 0x04; //NES set clock high
L10035:
	lda	#4
	sta	24576
;                {asm nop;}
	nop
;                {asm nop;}
	nop
;                {asm nop;}
	nop
;                *(unsigned char*)PORTB = 0x00; //NES set clock low
	stx	24576
;            }
	jmp	L10031
L10033:
;            if (nes_current1 != nes_controller1) {
	ldy	#251
	lda	(54),Y
	ldy	#253
	cmp	(54),Y
	bne	L44
	jmp	L10036
L44:
;                lcd_send_instruction_async(0x02, 0);  //set display to home
	phx
	phx
	phx
	lda	#2
	pha
	jsr	_lcd_send_instruction_async
;                print_string("CONTROLLER1 ");
	lda	#>L1+16
	pha
	lda	#<L1+16
	pha
	jsr	_print_string
;                print_byte(nes_current1);
	pha
	ldy	#251
	lda	(54),Y
	pha
	jsr	_print_byte
;            }
;            set_timer_1(0x411b);
L10036:
	lda	#65
	pha
	lda	#27
	pha
	jsr	_set_timer_1
;        }
;        if(*(unsigned char*)TIMER2){
L10028:
	lda	4379
	bne	L45
	jmp	L10037
L45:
;            *(unsigned char*)PORTB = 0x00;
	stx	24576
;            *(unsigned char*)TIMER2 = 0x00;
	stx	4379
;            set_timer_1(0x411b);
	lda	#65
	pha
	lda	#27
	pha
	jsr	_set_timer_1
;        }
;        
;    }
L10037:
	jmp	L10023
;}
L32	equ	0
L33	equ	-8
	ends
	efunc
	data
L1:
	db	$53,$48,$49,$46,$54,$20,$00,$43,$4F,$55,$4E,$54,$45,$52,$20
	db	$00,$43,$4F,$4E,$54,$52,$4F,$4C,$4C,$45,$52,$31,$20,$00
	ends
;
	end
