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

 ;RAM
COUNTER EQU $1000
SHIFT   EQU $1002
MESSAGE EQU $1004
SERIAL  EQU $1014
ASMWORK EQU $1015
LSTIRQ  EQU $1016
TIMER1  EQU $111a
TIMER2  EQU $111b

RESET
        ldx #$ff
        txs
        ldx #$ff
        lda #$00
        
INIT
        sta $00,x
        dex
        bne INIT

        lda #$c0  ;set psuedo-stack pointer to 2fc0--default is 7fc0
        sta $0032
        lda #$3f
        sta $0033
       
        cli   ; enable interupts
        XREF _main
        jmp _main

NMI
        rti

IRQ
        pha
        phx
        phy
        ldx IFRG
        stx ASMWORK
        stx LSTIRQ
        lda ASMWORK
        and #$80 ;check interrupt flag set
        beq IRQEND ; not set return

        rol ASMWORK
        lda ASMWORK
        and #$80; check Timer1
        beq CHKTM2
        ;do whatever for timer1
        inc TIMER1
CHKTM2
        rol ASMWORK
        lda ASMWORK
        and #$80 ; check Timer2
        beq CHKCB1
        ;do whatever for timer2
        inc TIMER2
CHKCB1
        rol ASMWORK
        lda ASMWORK
        and #$80
        beq CHKCB2
        ;do whatever for CB1
        inc SHIFT
CHKCB2
        rol ASMWORK
        lda ASMWORK
        and #$80
        beq CHKSHF
        ;do whatever for CB2
CHKSHF  
        rol ASMWORK
        lda ASMWORK
        and #$80
        beq CHKCA1
        ;do whatever for SHF
CHKCA1
        rol ASMWORK
        lda ASMWORK
        and #$80
        beq CHKCA2
        ;do whatever for CA1
        inc COUNTER
        bne CHKCA2
        inc COUNTER+1
CHKCA2
        rol ASMWORK
        lda ASMWORK
        and #$80
        beq IRQRST
        ;do whatever for CA1
IRQRST
        ldx #$7f 
        stx IFRG ;clear all interrupts
IRQEND

        ply
        plx
        pla
        rti

STARTUP SECTION
        word NMI
        word RESET
        word IRQ
ENDS