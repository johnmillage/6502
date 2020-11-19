PORTB EQU $6000
PORTA EQU $6001
DDRB  EQU $6002
DDRA  EQU $6003

 ;LCD register bits
E   EQU %10000000
RW  EQU %01000000
RS  EQU %00100000

RESET
        lda #%111111111 ;set all pins on port B to output
        sta DDRB

        lda #%11100000
        sta DDRA ;set first three pins of port a to output

        lda #%00111000 ; set 8 bit mode, 2 line display, and font
        sta PORTB

        lda #0
        sta PORTA

        lda #E
        sta PORTA

        lda #0
        sta PORTA

        lda #%00001110 ; turn on display and set cursor
        sta PORTB

        lda #0
        sta PORTA

        lda #E
        sta PORTA

        lda #0
        sta PORTA

        lda #%00000110 ; increment and shift cursor
        sta PORTB

        lda #0
        sta PORTA

        lda #E
        sta PORTA

        lda #0
        sta PORTA

        lda #"H"
        sta PORTB

        lda #RS
        sta PORTA

        lda #(RS|E)
        sta PORTA

        lda #RS
        sta PORTA

LOOP
        jmp LOOP

STARTUP SECTION
        word RESET
        word $0000
ENDS