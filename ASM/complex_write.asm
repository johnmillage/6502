 ; W65C22S registers 
PORTB EQU $6000  ;in/out PortB
PORTA EQU $6001  ;in/out PortA
DDRB  EQU $6002  ;Data Direction PortB
DDRA  EQU $6003  ;Data Direction PortA
T1CL  EQU $6004  ;Timer 1 low order counter
TICH  EQU $6005  ;Timer 1 high order counter
T1LL  EQU $6006  ;Timer 1 low order latch
T1LH  EQU $6007  ;Timer 1 high order latch
T2CL  EQU $6008  ;Timer 2 low order counter
T2CH  EQU $6009  ;Timer 2 high order counter
SHRG  EQU $600a  ;Shift register
ACRG  EQU $600b  ;Aux control register
PCRG  EQU $600c  ;Peripheral register
IFRG  EQU $600d  ;Interrupt flag register
IERG  EQU $600e  ;Interrupt Enable register
ORAH  EQU $600f  ;in/out PortA w/o handshake

 ;LCD register bits
E   EQU %10000000  ;Enable
RW  EQU %01000000  ;Read/Write
RS  EQU %00100000  ;Select

RESET
        ldx #$ff
        txs

        lda #%11111111 ;set all pins on port B to output
        sta DDRB

        lda #%11100000
        sta DDRA ;set first three pins of port a to output

        lda #%00111000 ; set 8 bit mode, 2 line display, and font
        jsr LCD_INSTRUCTION

        lda #%00001110 ; turn on display and set cursor
        jsr LCD_INSTRUCTION

        lda #%00000110 ; increment and shift cursor
        jsr LCD_INSTRUCTION

        lda #%00000001 ; clear the screen
        jsr LCD_INSTRUCTION

        ldx #0
PRINT
        lda MESG,x
        beq LOOP
        jsr PRINT_CHAR
        inx
        jmp PRINT

LOOP
        jmp LOOP

MESG    ASCII HEY JOHN
        BYTE

LCD_WAIT
        pha
        lda #%00000000  ;port b as input
        sta DDRB
LCD_BUSY
        lda #RW
        sta PORTA
        lda #(RW|E)
        sta PORTA
        lda PORTB
        and #%10000000
        bne LCD_BUSY
        
        lda #RW
        sta PORTA
        lda #%11111111 ;port b as output
        sta DDRB
        pla
        rts

LCD_INSTRUCTION
        jsr LCD_WAIT
        sta PORTB  ;send A register to portB
        lda #0
        sta PORTA  ;clear lcd bits
        lda #E
        sta PORTA  ;send Enable to PortA
        lda #0
        sta PORTA  ;clear lcd bits
        rts

PRINT_CHAR
        jsr LCD_WAIT
        sta PORTB  ;send A register to portB
        lda #RS
        sta PORTA  ;send select to portA
        lda #(RS|E)
        sta PORTA  ;send select and enable to portA
        lda #RS
        sta PORTA  ;send selct to portA
        rts

STARTUP SECTION
        word RESET
        word $0000
ENDS