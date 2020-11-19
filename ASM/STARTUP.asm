PORTA   EQU $6001  ;in/out PortA
COUNTER EQU $1000

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
        inc COUNTER
        bne EXIT_IRQ
        inc COUNTER+1

EXIT_IRQ
        bit PORTA ; read port A to clear interupt flag
        rti

STARTUP SECTION
        word NMI
        word RESET
        word IRQ
ENDS