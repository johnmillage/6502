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
;#define NES_A     0x80
;#define NES_B     0x40
;#define NES_SEL   0x20
;#define NES_ST    0x10
;#define NES_UP    0x08
;#define NES_DOWN  0x04
;#define NES_LEFT  0x02
;#define NES_RIGHT 0x01
;
; // player sprites
;#define P1_STAND 0x00
;#define P1_SQUAT 0x01
;#define P1_PUNCH 0x02
;#define P1_KICK  0x03
;#define P2_STAND 0x04
;#define P2_SQUAT 0x05
;#define P2_PUNCH 0x06
;#define P2_KICK  0x07
;
;// game states
;#define GAME_START 0x01
;#define GAME_RD1   0x02
;#define GAME_RD2   0x03
;#define GAME_RD3   0x04
;#define GAME_RD1F  0x05
;#define GAME_RD2F  0x06
;#define GAME_RD3F  0x07
;#define GAME_END   0x08
;
;#define LEFT_MOST  0x40
;#define RIGHT_MOST 0x4f
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
;#define PLAY1POS  0x1120  //player 1 position, 1 byte
;#define PLAY2POS  0x1121  //player 2 position, 1 byte
;#define PLAY1LF   0x1122  //player 1 life, 1 byte
;#define PLAY2LF   0x1123  //player 2 life, byte
;#define STAGE_CT  0x1124  //state transition counter, 1 byte
;#define STAGE     0x1125  //current state, 1 byte
;#define CTRL1     0x1126  //controller 1 state, 1 byte
;#define CTRL2     0x1127  //controller 2 state, 1 byte
;#define PLAY1JP   0x1128  //player 1 jumping, 1 byte
;#define PLAY2JP   0x1129  //player 2 jumping, 1 byte
;
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
;    *(unsigned char*)DDRA = 0xff;  //set PORTA output
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
;void print_nes(unsigned char b) {
	code
	xdef	_print_nes
	func
_print_nes:
b_0	set	9
	xref	~csav
	jsr	~csav
	db	2
	db	L29
	dw	L30
;    unsigned char i = 0;
;    if (b&0x80) {
	ldy	#255
	sta	(54),Y
	ldy	#9
	lda	(52),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#128
	bne	L31
	jmp	L10019
L31:
;        lcd_print_char_async('A');
	phx
	lda	#65
	pha
	jsr	_lcd_print_char_async
;    }
;    else {
	jmp	L10020
L10019:
;        lcd_print_char_async(' ');
	phx
	lda	#32
	pha
	jsr	_lcd_print_char_async
;    }
L10020:
;    if (b&0x40) {
	ldy	#9
	lda	(52),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#64
	bne	L32
	jmp	L10021
L32:
;        lcd_print_char_async('B');
	phx
	lda	#66
	pha
	jsr	_lcd_print_char_async
;    }
;    else {
	jmp	L10022
L10021:
;        lcd_print_char_async(' ');
	phx
	lda	#32
	pha
	jsr	_lcd_print_char_async
;    }
L10022:
;    if (b&0x20) {
	ldy	#9
	lda	(52),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#32
	bne	L33
	jmp	L10023
L33:
;        lcd_print_char_async('s');
	phx
	lda	#115
	pha
	jsr	_lcd_print_char_async
;    }
;    else {
	jmp	L10024
L10023:
;        lcd_print_char_async(' ');
	phx
	lda	#32
	pha
	jsr	_lcd_print_char_async
;    }
L10024:
;    if (b&0x10) {
	ldy	#9
	lda	(52),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#16
	bne	L34
	jmp	L10025
L34:
;        lcd_print_char_async('S');
	phx
	lda	#83
	pha
	jsr	_lcd_print_char_async
;    }
;    else {
	jmp	L10026
L10025:
;        lcd_print_char_async(' ');
	phx
	lda	#32
	pha
	jsr	_lcd_print_char_async
;    }
L10026:
;    if (b&0x08) {
	ldy	#9
	lda	(52),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#8
	bne	L35
	jmp	L10027
L35:
;        lcd_print_char_async('U');
	phx
	lda	#85
	pha
	jsr	_lcd_print_char_async
;    } 
;    else {
	jmp	L10028
L10027:
;        lcd_print_char_async(' ');
	phx
	lda	#32
	pha
	jsr	_lcd_print_char_async
;    }
L10028:
;    if (b&0x04) {
	ldy	#9
	lda	(52),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#4
	bne	L36
	jmp	L10029
L36:
;        lcd_print_char_async('D');
	phx
	lda	#68
	pha
	jsr	_lcd_print_char_async
;    }
;    else {
	jmp	L10030
L10029:
;        lcd_print_char_async(' ');
	phx
	lda	#32
	pha
	jsr	_lcd_print_char_async
;    }
L10030:
;    if (b&0x02) {
	ldy	#9
	lda	(52),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#2
	bne	L37
	jmp	L10031
L37:
;        lcd_print_char_async('L');
	phx
	lda	#76
	pha
	jsr	_lcd_print_char_async
;    }
;    else {
	jmp	L10032
L10031:
;        lcd_print_char_async(' ');
	phx
	lda	#32
	pha
	jsr	_lcd_print_char_async
;    }
L10032:
;    if (b&0x01) {
	ldy	#9
	lda	(52),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L38
	jmp	L10033
L38:
;        lcd_print_char_async('R');
	phx
	lda	#82
	pha
	jsr	_lcd_print_char_async
;    }
;    else {
	jmp	L10034
L10033:
;        lcd_print_char_async(' ');
	phx
	lda	#32
	pha
	jsr	_lcd_print_char_async
;    }
L10034:
;}
	rts
L29	equ	0
L30	equ	-1
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
	db	L39
	dw	L40
;    while(*str != 0) {
L10035:
	ldy	#9
	lda	(52),Y
	sta	<72
	iny
	lda	(52),Y
	sta	<73
	lda	(72)
	bne	L41
	jmp	L10036
L41:
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
	jmp	L10035
L10036:
;}
	rts
L39	equ	0
L40	equ	0
	ends
	efunc
;
;void load_custom_characters() {
	code
	xdef	_load_custom_characters
	func
_load_custom_characters:
	xref	~csav
	jsr	~csav
	db	0
	db	L42
	dw	L43
;    lcd_send_instruction_async(0x40, 0);  //set CGRAM address 0
	phx
	phx
	phx
	lda	#64
	pha
	jsr	_lcd_send_instruction_async
;    lcd_print_char_async(0x1c); //player 1 stand
	phx
	lda	#28
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x14);
	phx
	lda	#20
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x1c);
	phx
	lda	#28
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x08);
	phx
	lda	#8
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0c);
	phx
	lda	#12
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x08);
	phx
	lda	#8
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x14);
	phx
	lda	#20
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x14);
	phx
	lda	#20
	pha
	jsr	_lcd_print_char_async
;    lcd_send_instruction_async(0x48, 0);  //set CGRAM address 1
	phx
	phx
	phx
	lda	#72
	pha
	jsr	_lcd_send_instruction_async
;    lcd_print_char_async(0x00); //player 1 squat
	phx
	phx
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x1c); 
	phx
	lda	#28
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x14);
	phx
	lda	#20
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x1c);
	phx
	lda	#28
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x08);
	phx
	lda	#8
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0c);
	phx
	lda	#12
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x08);
	phx
	lda	#8
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x14);
	phx
	lda	#20
	pha
	jsr	_lcd_print_char_async
;    lcd_send_instruction_async(0x50, 0);  //set CGRAM address 2
	phx
	phx
	phx
	lda	#80
	pha
	jsr	_lcd_send_instruction_async
;    lcd_print_char_async(0x0e); //player 1 punch
	phx
	lda	#14
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0a);
	phx
	lda	#10
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0e);
	phx
	lda	#14
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x04);
	phx
	lda	#4
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x07);
	phx
	lda	#7
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x04);
	phx
	lda	#4
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0a);
	phx
	lda	#10
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0a);
	phx
	lda	#10
	pha
	jsr	_lcd_print_char_async
;    lcd_send_instruction_async(0x58, 0);  //set CGRAM address 3
	phx
	phx
	phx
	lda	#88
	pha
	jsr	_lcd_send_instruction_async
;    lcd_print_char_async(0x0e); //player 1 kick
	phx
	lda	#14
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0a);
	phx
	lda	#10
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0e);
	phx
	lda	#14
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x04);
	phx
	lda	#4
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0c);
	phx
	lda	#12
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x07);
	phx
	lda	#7
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x08);
	phx
	lda	#8
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x08);
	phx
	lda	#8
	pha
	jsr	_lcd_print_char_async
;    lcd_send_instruction_async(0x60, 0);  //set CGRAM address 4
	phx
	phx
	phx
	lda	#96
	pha
	jsr	_lcd_send_instruction_async
;    lcd_print_char_async(0x07); //player 2 stand
	phx
	lda	#7
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x05);
	phx
	lda	#5
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x07);
	phx
	lda	#7
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x02);
	phx
	lda	#2
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x06);
	phx
	lda	#6
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x02);
	phx
	lda	#2
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x05);
	phx
	lda	#5
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x05);
	phx
	lda	#5
	pha
	jsr	_lcd_print_char_async
;    lcd_send_instruction_async(0x68, 0);  //set CGRAM address 5
	phx
	phx
	phx
	lda	#104
	pha
	jsr	_lcd_send_instruction_async
;    lcd_print_char_async(0x00); //player 2 squat
	phx
	phx
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x07); 
	phx
	lda	#7
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x05);
	phx
	lda	#5
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x07);
	phx
	lda	#7
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x02);
	phx
	lda	#2
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x06);
	phx
	lda	#6
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x02);
	phx
	lda	#2
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x05);
	phx
	lda	#5
	pha
	jsr	_lcd_print_char_async
;    lcd_send_instruction_async(0x70, 0);  //set CGRAM address 6
	phx
	phx
	phx
	lda	#112
	pha
	jsr	_lcd_send_instruction_async
;    lcd_print_char_async(0x0e); //player 2 punch
	phx
	lda	#14
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0a); 
	phx
	lda	#10
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0e);
	phx
	lda	#14
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x04);
	phx
	lda	#4
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x1c);
	phx
	lda	#28
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x04);
	phx
	lda	#4
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0a);
	phx
	lda	#10
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0a);
	phx
	lda	#10
	pha
	jsr	_lcd_print_char_async
;    lcd_send_instruction_async(0x78, 0);  //set CGRAM address 6
	phx
	phx
	phx
	lda	#120
	pha
	jsr	_lcd_send_instruction_async
;    lcd_print_char_async(0x0e); //player 2 kick
	phx
	lda	#14
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0a); 
	phx
	lda	#10
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x0e);
	phx
	lda	#14
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x04);
	phx
	lda	#4
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x06);
	phx
	lda	#6
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x1c);
	phx
	lda	#28
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x02);
	phx
	lda	#2
	pha
	jsr	_lcd_print_char_async
;    lcd_print_char_async(0x02);
	phx
	lda	#2
	pha
	jsr	_lcd_print_char_async
;}
	rts
L42	equ	0
L43	equ	0
	ends
	efunc
;
;unsigned char get_controllers() {
	code
	xdef	_get_controllers
	func
_get_controllers:
	xref	~csav
	jsr	~csav
	db	0
	db	L44
	dw	L45
;    unsigned char nes_current1 = 0x00;
;    unsigned char nes_current2 = 0x00;
;    unsigned char nes_read = 0x00;
;    unsigned char idx = 0x00;
;    unsigned char nes_changed = 0x00;
;    *(unsigned char*)PORTB = 0x08; //NES set latch high
	ldy	#255
	sta	(54),Y
	dey
	sta	(54),Y
	dey
	sta	(54),Y
	dey
	sta	(54),Y
	dey
	sta	(54),Y
	lda	#8
	sta	24576
;    *(unsigned char*)TIMER1 = 0x00;
	stx	4378
;    {asm nop;}  //give latch some time
	nop
;    {asm nop;}
	nop
;    {asm nop;}
	nop
;    *(unsigned char*)PORTB = 0x00; //NES set latch low
	stx	24576
;
;    //now read first bits
;    nes_read = *(unsigned char*)PORTB;
	lda	24576
	ldy	#253
	sta	(54),Y
;    
;    if (nes_read&0x01) {
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L46
	jmp	L10037
L46:
;        nes_current1 = nes_current1<<1;
	lda	#1
	sta	<72
	stx	73
	ldy	#255
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#255
	sta	(54),Y
;        
;    } else {
	jmp	L10038
L10037:
;        nes_current1 = nes_current1<<1;
	lda	#1
	sta	<72
	stx	73
	ldy	#255
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#255
	sta	(54),Y
;        ++nes_current1;
	clc
	lda	#1
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
;    }
L10038:
;    nes_read = nes_read>>1;
	lda	#1
	sta	<72
	stx	73
	ldy	#253
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~lsr
	jsr	~lsr
	lda	<64
	ldy	#253
	sta	(54),Y
;    
;    if(nes_read&0x01) {
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L47
	jmp	L10039
L47:
;        nes_current2 = nes_current2<<1;
	lda	#1
	sta	<72
	stx	73
	ldy	#254
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#254
	sta	(54),Y
;    } else {
	jmp	L10040
L10039:
;        nes_current2 = nes_current2<<1;
	lda	#1
	sta	<72
	stx	73
	ldy	#254
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#254
	sta	(54),Y
;        ++nes_current2;
	clc
	lda	#1
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
;    }
L10040:
;    //pulse the clock
;    *(unsigned char*)PORTB = 0x04; //NES set clock high
	lda	#4
	sta	24576
;    {asm nop;}
	nop
;    {asm nop;}
	nop
;    {asm nop;}
	nop
;    *(unsigned char*)PORTB = 0x00; //NES set clock low
	stx	24576
;
;    for(idx = 0x00; idx < 0x07;++idx){
	txa
	ldy	#252
	sta	(54),Y
	jmp	L10042
L10041:
	clc
	lda	#1
	ldy	#252
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
L10042:
	ldy	#252
	lda	(54),Y
	cmp	#7
	bcc	L48
	jmp	L10043
L48:
;        nes_read = *(unsigned char*)PORTB;
	lda	24576
	ldy	#253
	sta	(54),Y
;        
;        if (nes_read&0x01) {
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L49
	jmp	L10044
L49:
;            nes_current1 = nes_current1<<1;
	lda	#1
	sta	<72
	stx	73
	ldy	#255
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#255
	sta	(54),Y
;        } else {
	jmp	L10045
L10044:
;            nes_current1 = nes_current1<<1;
	lda	#1
	sta	<72
	stx	73
	ldy	#255
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#255
	sta	(54),Y
;            ++nes_current1;
	clc
	lda	#1
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
;        }
L10045:
;        nes_read = nes_read>>1;
	lda	#1
	sta	<72
	stx	73
	ldy	#253
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~lsr
	jsr	~lsr
	lda	<64
	ldy	#253
	sta	(54),Y
;        
;        if(nes_read&0x01) {
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L50
	jmp	L10046
L50:
;            nes_current2 = nes_current2<<1;
	lda	#1
	sta	<72
	stx	73
	ldy	#254
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#254
	sta	(54),Y
;        } else {
	jmp	L10047
L10046:
;            nes_current2 = nes_current2<<1;
	lda	#1
	sta	<72
	stx	73
	ldy	#254
	lda	(54),Y
	sta	<68
	stx	69
	ldy	#68
	ldx	#72
	lda	#64
	xref	~shl
	jsr	~shl
	lda	<64
	ldy	#254
	sta	(54),Y
;            ++nes_current2;
	clc
	lda	#1
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
;        }
L10047:
;        //pulse the clock again
;        *(unsigned char*)PORTB = 0x04; //NES set clock high
	lda	#4
	sta	24576
;        {asm nop;}
	nop
;        {asm nop;}
	nop
;        {asm nop;}
	nop
;        *(unsigned char*)PORTB = 0x00; //NES set clock low
	stx	24576
;    }
	jmp	L10041
L10043:
;    if (*(unsigned char*)CTRL1 != nes_current1) {
	lda	4390
	ldy	#255
	cmp	(54),Y
	bne	L51
	jmp	L10048
L51:
;        nes_changed = 0x01;
	lda	#1
	ldy	#251
	sta	(54),Y
;        *(unsigned char*)CTRL1 = nes_current1;
	ldy	#255
	lda	(54),Y
	sta	4390
;    }
;      if (*(unsigned char*)CTRL2 != nes_current2) {
L10048:
	lda	4391
	ldy	#254
	cmp	(54),Y
	bne	L52
	jmp	L10049
L52:
;        nes_changed = 0x01;
	lda	#1
	ldy	#251
	sta	(54),Y
;        *(unsigned char*)CTRL2 = nes_current2;
	ldy	#254
	lda	(54),Y
	sta	4391
;    }
;    return nes_changed;
L10049:
	ldy	#251
	lda	(54),Y
	sta	<56
	txa
	sta	<57
	rts
;    
;}
L44	equ	0
L45	equ	-5
	ends
	efunc
;
;void switch_to_round(unsigned char rd) {
	code
	xdef	_switch_to_round
	func
_switch_to_round:
rd_0	set	9
	xref	~csav
	jsr	~csav
	db	2
	db	L53
	dw	L54
;    *(unsigned char*)PLAY1POS = LEFT_MOST;
	lda	#64
	sta	4384
;    *(unsigned char*)PLAY2POS = RIGHT_MOST;
	lda	#79
	sta	4385
;    *(signed char*)PLAY1LF = 0x64;
	lda	#100
	sta	4386
;    *(signed char*)PLAY2LF = 0x64;
	sta	4387
;    lcd_send_instruction_async(0x01, 0x00);  //clear the screen
	phx
	phx
	phx
	phy
	jsr	_lcd_send_instruction_async
;    lcd_send_instruction_async(0x02, 0);  //set display to home
	phx
	phx
	phx
	lda	#2
	pha
	jsr	_lcd_send_instruction_async
;    print_string("    ROUND ");
	lda	#>L1
	pha
	lda	#<L1
	pha
	jsr	_print_string
;    lcd_print_char_async('0' + rd);
	ldy	#9
	lda	(52),Y
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
;    print_string("     ");
	lda	#>L1+11
	pha
	lda	#<L1+11
	pha
	jsr	_print_string
;    *(unsigned char*)STAGE_CT = 0x28;
	lda	#40
	sta	4388
;}
	rts
L53	equ	0
L54	equ	0
	ends
	efunc
	data
L1:
	db	$20,$20,$20,$20,$52,$4F,$55,$4E,$44,$20,$00,$20,$20,$20,$20
	db	$20,$00
	ends
;
;unsigned char check_fight_over() {
	code
	xdef	_check_fight_over
	func
_check_fight_over:
	xref	~csav
	jsr	~csav
	db	0
	db	L56
	dw	L57
;    if (*(signed char*)PLAY1LF <= 0x00 || *(signed char*)PLAY2LF <= 0x00) {
	sec
	sbc	4386
	bvs	L59
	eor	#$80
L59:
	bpl	L60
	jmp	L58
L60:
	txa
	sec
	sbc	4387
	bvs	L61
	eor	#$80
L61:
	bmi	L62
	jmp	L10050
L62:
L58:
;        if (*(unsigned char*)STAGE == GAME_RD1F) {
	lda	4389
	cmp	#5
	beq	L63
	jmp	L10051
L63:
;            *(unsigned char*)STAGE = GAME_RD2;
	lda	#3
	sta	4389
;            switch_to_round(0x02);
	phx
	lda	#2
	pha
	jsr	_switch_to_round
;            return 0x01;
	sty	<56
	stx	<57
	rts
;        }
;        else if(*(unsigned char*)STAGE == GAME_RD2F) {
L10051:
	lda	4389
	cmp	#6
	beq	L64
	jmp	L10052
L64:
;            *(unsigned char*)STAGE = GAME_RD3;
	lda	#4
	sta	4389
;            switch_to_round(0x03);
	phx
	lda	#3
	pha
	jsr	_switch_to_round
;            return 0x01;
	sty	<56
	stx	<57
	rts
;        }
;        else {
L10052:
;            *(unsigned char*)STAGE = GAME_START;
	lda	#1
	sta	4389
;            lcd_send_instruction_async(0x01, 0x00);  //clear the screen
	phx
	phx
	phx
	pha
	jsr	_lcd_send_instruction_async
;            lcd_send_instruction_async(0x02, 0x00);  //set display to home
	phx
	phx
	phx
	lda	#2
	pha
	jsr	_lcd_send_instruction_async
;            print_string("      START     ");
	lda	#>L55
	pha
	lda	#<L55
	pha
	jsr	_print_string
;            *(unsigned char*)STAGE_CT = 0x28;
	lda	#40
	sta	4388
;            return 0x01;
	sty	<56
	stx	<57
	rts
;        }
;    }
;    return 0x00;
L10050:
	stx	<56
	stx	<57
	rts
;}
L56	equ	0
L57	equ	0
	ends
	efunc
	data
L55:
	db	$20,$20,$20,$20,$20,$20,$53,$54,$41,$52,$54,$20,$20,$20,$20
	db	$20,$00
	ends
;
;unsigned char apply_hits() {
	code
	xdef	_apply_hits
	func
_apply_hits:
	xref	~csav
	jsr	~csav
	db	0
	db	L66
	dw	L67
;    unsigned char hits = 0x00;
;    // can't hit if either is jumping
;    if (*(unsigned char*)PLAY1JP || *(unsigned char*)PLAY2JP) {
	ldy	#255
	sta	(54),Y
	lda	4392
	beq	L69
	jmp	L68
L69:
	lda	4393
	bne	L70
	jmp	L10053
L70:
L68:
;        return hits;  
	ldy	#255
	lda	(54),Y
	sta	<56
	txa
	sta	<57
	rts
;    }
;
;    // are they right next to each other
;    if (*(unsigned char*)PLAY1POS == (*(unsigned char*)PLAY2POS - 0x01)) {
L10053:
	lda	4384
	sta	<72
	txa
	sta	<73
	lda	4385
	sta	<68
	txa
	sta	<69
	clc
	lda	#255
	adc	<68
	sta	<64
	lda	#255
	adc	<69
	sta	<65
	lda	<72
	cmp	<64
	bne	L10055
	lda	<73
	cmp	<65
L10055:
	beq	L71
	jmp	L10054
L71:
;        if(*(unsigned char*)CTRL1&NES_A) {
	lda	4390
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#128
	bne	L72
	jmp	L10056
L72:
;            if(*(unsigned char*)CTRL2&NES_A) {  //both punching knock back
	lda	4391
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#128
	bne	L73
	jmp	L10057
L73:
;                if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
	lda	4384
	cmp	#64
	bne	L74
	jmp	L10058
L74:
;                    --(*(unsigned char*)PLAY1POS);
	clc
	lda	#255
	adc	4384
	sta	4384
	lda	#255
	adc	#0
;                }
;                if (*(unsigned char*)PLAY2POS != RIGHT_MOST) {
L10058:
	lda	4385
	cmp	#79
	bne	L75
	jmp	L10059
L75:
;                    ++(*(unsigned char*)PLAY2POS);
	inc	4385
;                }
;                hits = 0x01;
L10059:
	lda	#1
	ldy	#255
	sta	(54),Y
;            }
;            else {  //P2 kicking or doing nothing,  gets hit
	jmp	L10060
L10057:
;                if (*(unsigned char*)PLAY2POS != RIGHT_MOST) {
	lda	4385
	cmp	#79
	bne	L76
	jmp	L10061
L76:
;                    ++(*(unsigned char*)PLAY2POS);
	inc	4385
;                }
;                (*(char*)PLAY2LF)-=0x0a;
L10061:
	lda	4387
	sta	<72
	txa
	sta	<73
	clc
	lda	#246
	adc	<72
	sta	<68
	lda	#255
	adc	<73
	sta	<69
	lda	<68
	sta	4387
;                hits = 0x01;
	lda	#1
	ldy	#255
	sta	(54),Y
;            }
L10060:
;        }
;        else if(*(unsigned char*)CTRL1&NES_B) {  //player 1 kicking
	jmp	L10062
L10056:
	lda	4390
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#64
	bne	L77
	jmp	L10063
L77:
;            if(*(unsigned char*)CTRL2&NES_A) {  //player 2 punching hits 1
	lda	4391
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#128
	bne	L78
	jmp	L10064
L78:
;                if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
	lda	4384
	cmp	#64
	bne	L79
	jmp	L10065
L79:
;                    --(*(unsigned char*)PLAY1POS);
	clc
	lda	#255
	adc	4384
	sta	4384
	lda	#255
	adc	#0
;                }
;                (*(signed char*)PLAY1LF)-=0x01;
L10065:
	clc
	lda	#255
	adc	4386
	sta	4386
;                hits = 0x01;
	lda	#1
	ldy	#255
	sta	(54),Y
;            }
;            else if(*(unsigned char*)CTRL2&NES_B) {  //both kicking,  knock back
	jmp	L10066
L10064:
	lda	4391
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#64
	bne	L80
	jmp	L10067
L80:
;                if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
	lda	4384
	cmp	#64
	bne	L81
	jmp	L10068
L81:
;                    --(*(unsigned char*)PLAY1POS);
	clc
	lda	#255
	adc	4384
	sta	4384
	lda	#255
	adc	#0
;                }
;                if (*(unsigned char*)PLAY2POS != RIGHT_MOST) {
L10068:
	lda	4385
	cmp	#79
	bne	L82
	jmp	L10069
L82:
;                    ++(*(unsigned char*)PLAY2POS);
	inc	4385
;                }
;                hits = 0x01;
L10069:
	lda	#1
	ldy	#255
	sta	(54),Y
;            } else {  //player 2 doing nothing, gets hit
	jmp	L10070
L10067:
;                if (*(unsigned char*)PLAY2POS != RIGHT_MOST) {
	lda	4385
	cmp	#79
	bne	L83
	jmp	L10071
L83:
;                    ++(*(unsigned char*)PLAY2POS);
	inc	4385
;                }
;                (*(char*)PLAY2LF)-=(char)0x0f;
L10071:
	lda	4387
	sta	<72
	txa
	sta	<73
	clc
	lda	#241
	adc	<72
	sta	<68
	lda	#255
	adc	<73
	sta	<69
	lda	<68
	sta	4387
;                hits = 0x01;
	lda	#1
	ldy	#255
	sta	(54),Y
;            }
L10070:
L10066:
;        } else if(*(unsigned char*)CTRL2&NES_A) {  //player 2 punching hits 1
	jmp	L10072
L10063:
	lda	4391
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#128
	bne	L84
	jmp	L10073
L84:
;            if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
	lda	4384
	cmp	#64
	bne	L85
	jmp	L10074
L85:
;                --(*(unsigned char*)PLAY1POS);
	clc
	lda	#255
	adc	4384
	sta	4384
	lda	#255
	adc	#0
;            }
;            (*(signed char*)PLAY1LF)-=0x0a;
L10074:
	clc
	lda	#246
	adc	4386
	sta	4386
;            hits = 0x01;
	lda	#1
	ldy	#255
	sta	(54),Y
;        } else if(*(unsigned char*)CTRL2&NES_B) {  //player 2 kicking hits 1
	jmp	L10075
L10073:
	lda	4391
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#64
	bne	L86
	jmp	L10076
L86:
;            if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
	lda	4384
	cmp	#64
	bne	L87
	jmp	L10077
L87:
;                --(*(unsigned char*)PLAY1POS);
	clc
	lda	#255
	adc	4384
	sta	4384
	lda	#255
	adc	#0
;            }
;            (*(signed char*)PLAY1LF)-=0x0f;
L10077:
	clc
	lda	#241
	adc	4386
	sta	4386
;            hits = 0x01;
	lda	#1
	ldy	#255
	sta	(54),Y
;        }
;    }
L10076:
L10075:
L10072:
L10062:
;    return hits;
L10054:
	ldy	#255
	lda	(54),Y
	sta	<56
	txa
	sta	<57
	rts
;}
L66	equ	0
L67	equ	-1
	ends
	efunc
;
;void draw_power() {
	code
	xdef	_draw_power
	func
_draw_power:
	xref	~csav
	jsr	~csav
	db	0
	db	L88
	dw	L89
;    char i = 0;
;    char pow = 0;
;    for(i = 0; i < 5; ++i) {
	ldy	#255
	sta	(54),Y
	dey
	sta	(54),Y
	iny
	sta	(54),Y
	jmp	L10079
L10078:
	clc
	lda	#1
	ldy	#255
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
L10079:
	ldy	#255
	lda	(54),Y
	cmp	#5
	bcc	L90
	jmp	L10080
L90:
;        pow += 20;
	clc
	lda	#20
	ldy	#254
	adc	(54),Y
	sta	(54),Y
;        if (*(char*)PLAY1LF >= pow) {
	lda	4386
	cmp	(54),Y
	bcs	L91
	jmp	L10081
L91:
;            lcd_print_char_async(0xdb);
	phx
	lda	#219
	pha
	jsr	_lcd_print_char_async
;        } else if (*(char*)PLAY1LF >= (pow - 10)){
	jmp	L10082
L10081:
	lda	4386
	sta	<72
	txa
	sta	<73
	ldy	#254
	lda	(54),Y
	sta	<68
	txa
	sta	<69
	clc
	lda	#246
	adc	<68
	sta	<64
	lda	#255
	adc	<69
	sta	<65
	lda	<72
	cmp	<64
	lda	<73
	sbc	<65
	bvs	L92
	eor	#$80
L92:
	bmi	L93
	jmp	L10083
L93:
;            lcd_print_char_async(0xa1);
	phx
	lda	#161
	pha
	jsr	_lcd_print_char_async
;        }
;    }
L10083:
L10082:
	jmp	L10078
L10080:
;    lcd_send_instruction_async(0x8b, 0x00);  //set mid through first line
	phx
	phx
	phx
	lda	#139
	pha
	jsr	_lcd_send_instruction_async
;    pow = 100;
	lda	#100
	ldy	#254
	sta	(54),Y
;     for(i = 0; i < 5; ++i) {
	txa
	iny
	sta	(54),Y
	jmp	L10085
L10084:
	clc
	lda	#1
	ldy	#255
	adc	(54),Y
	sta	(54),Y
	txa
	adc	#0
L10085:
	ldy	#255
	lda	(54),Y
	cmp	#5
	bcc	L94
	jmp	L10086
L94:
;        
;        if (*(char*)PLAY2LF >= pow) {
	lda	4387
	ldy	#254
	cmp	(54),Y
	bcs	L95
	jmp	L10087
L95:
;            lcd_print_char_async(0xdb);
	phx
	lda	#219
	pha
	jsr	_lcd_print_char_async
;        } else if (*(char*)PLAY2LF >= (pow - 10)){
	jmp	L10088
L10087:
	lda	4387
	sta	<72
	txa
	sta	<73
	ldy	#254
	lda	(54),Y
	sta	<68
	txa
	sta	<69
	clc
	lda	#246
	adc	<68
	sta	<64
	lda	#255
	adc	<69
	sta	<65
	lda	<72
	cmp	<64
	lda	<73
	sbc	<65
	bvs	L96
	eor	#$80
L96:
	bmi	L97
	jmp	L10089
L97:
;            lcd_print_char_async(0xa1);
	phx
	lda	#161
	pha
	jsr	_lcd_print_char_async
;        } else {
	jmp	L10090
L10089:
;            lcd_print_char_async(' ');
	phx
	lda	#32
	pha
	jsr	_lcd_print_char_async
;        }
L10090:
L10088:
;        pow -= 20;
	ldy	#254
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	clc
	lda	#236
	adc	<72
	sta	<68
	lda	#255
	adc	<73
	sta	<69
	lda	<68
	sta	(54),Y
;        
;    }
	jmp	L10084
L10086:
;}
	rts
L88	equ	0
L89	equ	-2
	ends
	efunc
;
;void draw_scene() {
	code
	xdef	_draw_scene
	func
_draw_scene:
	xref	~csav
	jsr	~csav
	db	0
	db	L98
	dw	L99
;    unsigned char p1_sprite = P1_STAND;
;    unsigned char p2_sprite = P2_STAND;
;    unsigned char ctrl1 = *(unsigned char*)CTRL1;
;    unsigned char ctrl2 = *(unsigned char*)CTRL2;
;    lcd_send_instruction_async(0x01, 0x00);  //clear the screen
	ldy	#255
	sta	(54),Y
	lda	#4
	dey
	sta	(54),Y
	lda	4390
	dey
	sta	(54),Y
	lda	4391
	dey
	sta	(54),Y
	phx
	phx
	phx
	lda	#1
	pha
	jsr	_lcd_send_instruction_async
;    draw_power();
	jsr	_draw_power
;    if (*(unsigned char*)PLAY1JP == 0x00) {
	lda	4392
	beq	L100
	jmp	L10091
L100:
;       
;        if (ctrl1&NES_UP) {
	ldy	#253
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#8
	bne	L101
	jmp	L10092
L101:
;            *(unsigned char*)PLAY1POS = *(unsigned char*)PLAY1POS - 0x40;
	lda	4384
	sta	<72
	txa
	sta	<73
	clc
	lda	#192
	adc	<72
	sta	<68
	lda	#255
	adc	<73
	sta	<69
	lda	<68
	sta	4384
;            *(unsigned char*)PLAY1JP = 0x05;
	lda	#5
	sta	4392
;        } 
;        else {
	jmp	L10093
L10092:
;            if(ctrl1&NES_LEFT) {
	ldy	#253
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#2
	bne	L102
	jmp	L10094
L102:
;                if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
	lda	4384
	cmp	#64
	bne	L103
	jmp	L10095
L103:
;                    --(*(unsigned char*)PLAY1POS);
	clc
	lda	#255
	adc	4384
	sta	4384
	lda	#255
	adc	#0
;                }
;            }
L10095:
;            if(ctrl1&NES_RIGHT) {
L10094:
	ldy	#253
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L104
	jmp	L10096
L104:
;                if (*(unsigned char*)PLAY1POS != RIGHT_MOST) {
	lda	4384
	cmp	#79
	bne	L105
	jmp	L10097
L105:
;                    ++(*(unsigned char*)PLAY1POS);
	inc	4384
;                }
;            }
L10097:
;
;            if(ctrl1&NES_A) {
L10096:
	ldy	#253
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#128
	bne	L106
	jmp	L10098
L106:
;                p1_sprite = P1_PUNCH;
	lda	#2
	ldy	#255
	sta	(54),Y
;            } else if (ctrl1&NES_B) {
	jmp	L10099
L10098:
	ldy	#253
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#64
	bne	L107
	jmp	L10100
L107:
;                p1_sprite = P1_KICK;
	lda	#3
	ldy	#255
	sta	(54),Y
;            }
;        }
L10100:
L10099:
L10093:
;
;    }
;    else {
	jmp	L10101
L10091:
;        --(*(unsigned char*)PLAY1JP);
	clc
	lda	#255
	adc	4392
	sta	4392
	lda	#255
	adc	#0
;        if (*(unsigned char*)PLAY1JP == 0x00) {
	lda	4392
	beq	L108
	jmp	L10102
L108:
;            *(unsigned char*)PLAY1POS = *(unsigned char*)PLAY1POS + 0x40;
	clc
	lda	#64
	adc	4384
	sta	4384
;        }
;    }
L10102:
L10101:
;
;    if (*(unsigned char*)PLAY2JP == 0x00) {
	lda	4393
	beq	L109
	jmp	L10103
L109:
;       
;        if (ctrl2&NES_UP) {
	ldy	#252
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#8
	bne	L110
	jmp	L10104
L110:
;            *(unsigned char*)PLAY2POS = *(unsigned char*)PLAY2POS - 0x40;
	lda	4385
	sta	<72
	txa
	sta	<73
	clc
	lda	#192
	adc	<72
	sta	<68
	lda	#255
	adc	<73
	sta	<69
	lda	<68
	sta	4385
;            *(unsigned char*)PLAY2JP = 0x05;
	lda	#5
	sta	4393
;        } 
;        else {
	jmp	L10105
L10104:
;             if(ctrl2&NES_LEFT) {
	ldy	#252
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#2
	bne	L111
	jmp	L10106
L111:
;                if (*(unsigned char*)PLAY2POS != LEFT_MOST) {
	lda	4385
	cmp	#64
	bne	L112
	jmp	L10107
L112:
;                    --(*(unsigned char*)PLAY2POS);
	clc
	lda	#255
	adc	4385
	sta	4385
	lda	#255
	adc	#0
;                }
;            }
L10107:
;            if(ctrl2&NES_RIGHT) {
L10106:
	ldy	#252
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L113
	jmp	L10108
L113:
;                if (*(unsigned char*)PLAY2POS != RIGHT_MOST) {
	lda	4385
	cmp	#79
	bne	L114
	jmp	L10109
L114:
;                    ++(*(unsigned char*)PLAY2POS);
	inc	4385
;                }
;            }
L10109:
;            if(ctrl2&NES_A) {
L10108:
	ldy	#252
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#128
	bne	L115
	jmp	L10110
L115:
;                p2_sprite = P2_PUNCH;
	lda	#6
	ldy	#254
	sta	(54),Y
;            } else if (ctrl2&NES_B) {
	jmp	L10111
L10110:
	ldy	#252
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#64
	bne	L116
	jmp	L10112
L116:
;                p2_sprite = P2_KICK;
	lda	#7
	ldy	#254
	sta	(54),Y
;            }
;        }
L10112:
L10111:
L10105:
;    } else {
	jmp	L10113
L10103:
;        --(*(unsigned char*)PLAY2JP);
	clc
	lda	#255
	adc	4393
	sta	4393
	lda	#255
	adc	#0
;        if (*(unsigned char*)PLAY2JP == 0x00) {
	lda	4393
	beq	L117
	jmp	L10114
L117:
;            
;            *(unsigned char*)PLAY2POS = *(unsigned char*)PLAY2POS + 0x40;
	clc
	lda	#64
	adc	4385
	sta	4385
;        }
;    }
L10114:
L10113:
;
;    if ((*(unsigned char*)PLAY1POS&0x0f) >= (*(unsigned char*)PLAY2POS&0x0f)) {  //at same spot
	lda	4384
	sta	<72
	txa
	sta	<73
	lda	#15
	and	<72
	sta	<68
	txa
	sta	<69
	lda	4385
	sta	<72
	txa
	sta	<73
	lda	#15
	and	<72
	sta	<64
	txa
	sta	<65
	lda	<68
	cmp	<64
	lda	<69
	sbc	<65
	bvs	L118
	eor	#$80
L118:
	bmi	L119
	jmp	L10115
L119:
;        if(ctrl1&NES_RIGHT) {  //if player 1 moved right move back
	ldy	#253
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#1
	bne	L120
	jmp	L10116
L120:
;            --(*(unsigned char*)PLAY1POS);
	clc
	lda	#255
	adc	4384
	sta	4384
	lda	#255
	adc	#0
;        }
;        if(ctrl2&NES_LEFT){ //if player 2 moved left move back
L10116:
	ldy	#252
	lda	(54),Y
	sta	<72
	txa
	sta	<73
	lda	<72
	and	#2
	bne	L121
	jmp	L10117
L121:
;            ++(*(unsigned char*)PLAY2POS);
	inc	4385
;        }
;        
;    }
L10117:
;
;    lcd_send_instruction_async(0x80|*(unsigned char*)PLAY1POS, 0x00);
L10115:
	phx
	phx
	lda	4384
	sta	<72
	txa
	sta	<73
	lda	#128
	ora	<72
	sta	<68
	lda	<73
	sta	<69
	txa
	pha
	lda	<68
	pha
	jsr	_lcd_send_instruction_async
;    lcd_print_char_async(p1_sprite);
	pha
	ldy	#255
	lda	(54),Y
	pha
	jsr	_lcd_print_char_async
;    lcd_send_instruction_async(0x80|*(unsigned char*)PLAY2POS, 0x00);
	phx
	phx
	lda	4385
	sta	<72
	txa
	sta	<73
	lda	#128
	ora	<72
	sta	<68
	lda	<73
	sta	<69
	txa
	pha
	lda	<68
	pha
	jsr	_lcd_send_instruction_async
;    lcd_print_char_async(p2_sprite);
	pha
	ldy	#254
	lda	(54),Y
	pha
	jsr	_lcd_print_char_async
;}
	rts
L98	equ	0
L99	equ	-4
	ends
	efunc
;
;
;
;void main() {
	code
	xdef	_main
	func
_main:
	xref	~csav
	jsr	~csav
	db	0
	db	L122
	dw	L123
;    unsigned char last_shift;
;    unsigned char last_counter;
;    unsigned char last_hits;
;    unsigned char nes_changed;
;    *(unsigned char*)IERG = 0xf2;  //set CA1 AND CB1 Interrupt enable
	lda	#242
	sta	24590
;    *(unsigned char*)PCRG = 0x00;  //set CA's to active edge low
	stx	24588
;    
;    *(unsigned char*)ACRG = 0x0c; //set shift in ACRG
	lda	#12
	sta	24587
;    *(unsigned char*)DDRA = 0xef;  //set PORTA output - except last pin of first nibble
	lda	#239
	sta	24579
;    *(unsigned char*)DDRB = 0x0c;  //set PORTB output on last 2 pins of first nibble, others input
	lda	#12
	sta	24578
;    *(unsigned char*)SHIFT = 0x00;
	stx	4098
;    *(unsigned char*)KEYCODE = 0x00;
	stx	4118
;    *(unsigned char*)COUNTER = 0;
	stx	4096
;    *(unsigned char*)TIMER1 = 0x00;
	stx	4378
;    *(unsigned char*)TIMER2 = 0x00;
	stx	4379
;    *(unsigned char*)CTRL1 = 0x00;
	stx	4390
;    *(unsigned char*)CTRL2 = 0x00;
	stx	4391
;    *(unsigned char*)PLAY1JP = 0x00;
	stx	4392
;    *(unsigned char*)PLAY2JP = 0x00;
	stx	4393
;    last_counter = 0;
	txa
	ldy	#254
	sta	(54),Y
;    last_shift = 0x00;
	iny
	sta	(54),Y
;    last_hits = 0x01;  //set to 1 so that you force redraw
	lda	#1
	ldy	#253
	sta	(54),Y
;    *(unsigned char*)QUESTART = 0x00;
	stx	4119
;    *(unsigned char*)QUEEND = 0x00;
	stx	4120
;
;    lcd_send_instruction_async(0x20, 0x01);  //set 4 bit mode
	phx
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
;    load_custom_characters();
	jsr	_load_custom_characters
;    lcd_send_instruction_async(0x0c, 0x00);  // turn on display
	phx
	phx
	phx
	lda	#12
	pha
	jsr	_lcd_send_instruction_async
;    
;    lcd_send_instruction_async(0x06, 0x00);  //increment and shift cursor
	phx
	phx
	phx
	lda	#6
	pha
	jsr	_lcd_send_instruction_async
;
;    lcd_send_instruction_async(0x02, 0);  //set display to home
	phx
	phx
	phx
	lda	#2
	pha
	jsr	_lcd_send_instruction_async
;    *(unsigned char*)STAGE = GAME_START;
	sty	4389
;    *(unsigned char*)STAGE_CT = 0x28;
	lda	#40
	sta	4388
;    print_string("      START     ");
	lda	#>L65
	pha
	lda	#<L65
	pha
	jsr	_print_string
;
;    //flush all the sends
;    while(check_lcd_send()) {}
L10118:
	jsr	_check_lcd_send
	lda	<56
	bne	L124
	jmp	L10119
L124:
	jmp	L10118
L10119:
;
;
;    //done with startup
;    set_timer_2(0xffff);  //50ms
	lda	#255
	pha
	pha
	jsr	_set_timer_2
;    while(1) {
L10120:
;        //see if we can drain the lcd stack
;        check_lcd_send();
	jsr	_check_lcd_send
;        if(*(unsigned char*)TIMER2){
	lda	4379
	bne	L125
	jmp	L10122
L125:
;            if (*(unsigned char*)STAGE == GAME_START || 
;            *(unsigned char*)STAGE == GAME_RD1 ||
;            *(unsigned char*)STAGE == GAME_RD2 ||
;            *(unsigned char*)STAGE == GAME_RD3 ) {
	lda	4389
	cmp	#1
	bne	L127
	jmp	L126
L127:
	lda	4389
	cmp	#2
	bne	L128
	jmp	L126
L128:
	lda	4389
	cmp	#3
	bne	L129
	jmp	L126
L129:
	lda	4389
	cmp	#4
	beq	L130
	jmp	L10123
L130:
L126:
;                --(*(unsigned char*)STAGE_CT);
	clc
	lda	#255
	adc	4388
	sta	4388
	lda	#255
	adc	#0
;                  // going from start of state
;                if (*(unsigned char*)STAGE_CT == 0x00) {
	lda	4388
	beq	L131
	jmp	L10124
L131:
;                    if (*(unsigned char*)STAGE == GAME_START) {
	lda	4389
	cmp	#1
	beq	L132
	jmp	L10125
L132:
;                        *(unsigned char*)STAGE = GAME_RD1;
	lda	#2
	sta	4389
;                        switch_to_round(0x01);
	phx
	lda	#1
	pha
	jsr	_switch_to_round
;                    } else if (*(unsigned char*)STAGE == GAME_RD1) {
	jmp	L10126
L10125:
	lda	4389
	cmp	#2
	beq	L133
	jmp	L10127
L133:
;                        *(unsigned char*)STAGE = GAME_RD1F;
	lda	#5
	sta	4389
;                        last_hits = 0x01;
	lda	#1
	ldy	#253
	sta	(54),Y
;                    } else if (*(unsigned char*)STAGE == GAME_RD2) {
	jmp	L10128
L10127:
	lda	4389
	cmp	#3
	beq	L134
	jmp	L10129
L134:
;                        *(unsigned char*)STAGE = GAME_RD2F;
	lda	#6
	sta	4389
;                        last_hits = 0x01;
	lda	#1
	ldy	#253
	sta	(54),Y
;                    } else if (*(unsigned char*)STAGE == GAME_RD3) {
	jmp	L10130
L10129:
	lda	4389
	cmp	#4
	beq	L135
	jmp	L10131
L135:
;                        *(unsigned char*)STAGE = GAME_RD3F;
	lda	#7
	sta	4389
;                        last_hits = 0x01;
	lda	#1
	ldy	#253
	sta	(54),Y
;                    }
;
;                }
L10131:
L10130:
L10128:
L10126:
;            } else {
L10124:
	jmp	L10132
L10123:
;                nes_changed = get_controllers();
	jsr	_get_controllers
	lda	<56
	ldy	#252
	sta	(54),Y
;                if(check_fight_over() == 0x00) {
	jsr	_check_fight_over
	lda	<56
	beq	L136
	jmp	L10133
L136:
;                    //if nothing pressed and no one is jumping nothing to do
;                    if(nes_changed|last_hits|*(unsigned char*)PLAY1JP|*(unsigned char*)PLAY2JP) {
	lda	4393
	sta	<72
	txa
	sta	<73
	lda	4392
	sta	<68
	txa
	sta	<69
	ldy	#253
	lda	(54),Y
	sta	<64
	txa
	sta	<65
	dey
	lda	(54),Y
	sta	<60
	txa
	sta	<61
	lda	<60
	ora	<64
	sta	<56
	lda	<61
	ora	<65
	sta	<57
	lda	<56
	ora	<68
	sta	<64
	lda	<57
	ora	<69
	sta	<65
	lda	<64
	ora	<72
	sta	<68
	lda	<65
	ora	<73
	sta	<69
	lda	<68
	ora	<69
	bne	L137
	jmp	L10134
L137:
;                        draw_scene();
	jsr	_draw_scene
;                        last_hits = apply_hits();
	jsr	_apply_hits
	lda	<56
	ldy	#253
	sta	(54),Y
;                    }
;                }
L10134:
;            }
L10133:
L10132:
;            set_timer_2(0xffff);
	lda	#255
	pha
	pha
	jsr	_set_timer_2
;            *(unsigned char*)TIMER2 = 0x00;
	stx	4379
;        }
;        
;    }
L10122:
	jmp	L10120
;}
L122	equ	0
L123	equ	-4
	ends
	efunc
	data
L65:
	db	$20,$20,$20,$20,$20,$20,$53,$54,$41,$52,$54,$20,$20,$20,$20
	db	$20,$00
	ends
;
	end
