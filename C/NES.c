#define USING_02 1
#include "INTRINS.H"
 // W65C22S registers 
#define PORTB 0x6000  // in/out PortB
#define PORTA 0x6001  // in/out PortA
#define DDRB  0x6002  // Data Direction PortB
#define DDRA  0x6003  // Data Direction PortA
#define T1CL  0x6004  // Timer 1 low order counter
#define T1CH  0x6005  // Timer 1 high order counter
#define T1LL  0x6006  // Timer 1 low order latch
#define T1LH  0x6007  // Timer 1 high order latch
#define T2CL  0x6008  // Timer 2 low order counter
#define T2CH  0x6009  // Timer 2 high order counter
#define SHRG  0x600a  // Shift register
#define ACRG  0x600b  // Aux control register
#define PCRG  0x600c  // Peripheral register
#define IFRG  0x600d  // Interrupt flag register
#define IERG  0x600e  // Interrupt Enable register
#define ORAH  0x600f  // in/out PortA w/o handshake

#define HIGH  0xf0
#define LOW   0x0f

 // LCD register bits
#define LCD_E     0x80  // Enable
#define LCD_R     0x40  // Read -write is 0
#define LCD_RS    0x20  // register Select
#define LCD_BUSY  0x08  // busy flag

#define NES_A     0x80
#define NES_B     0x40
#define NES_SEL   0x20
#define NES_ST    0x10
#define NES_UP    0x08
#define NES_DOWN  0x04
#define NES_LEFT  0x02
#define NES_RIGHT 0x01

 // player sprites
#define P1_STAND 0x00
#define P1_SQUAT 0x01
#define P1_PUNCH 0x02
#define P1_KICK  0x03
#define P2_STAND 0x04
#define P2_SQUAT 0x05
#define P2_PUNCH 0x06
#define P2_KICK  0x07

// game states
#define GAME_START 0x01
#define GAME_RD1   0x02
#define GAME_RD2   0x03
#define GAME_RD3   0x04
#define GAME_RD1F  0x05
#define GAME_RD2F  0x06
#define GAME_RD3F  0x07
#define GAME_END   0x08

#define LEFT_MOST  0x40
#define RIGHT_MOST 0x4f

#define RAM_START 0x1000 
#define COUNTER   0x1000 // 2 byte counter
#define SHIFT     0x1002 // 1 byte shift counter
#define MESSAGE   0x1004  //16 bytes
#define SERIAL    0x1014  //1 byte
#define ASKWORK   0x1015  //1 byte
#define KEYCODE   0x1016  //1 byte
#define QUESTART  0x1017  //1 byte lcd queue start index
#define QUEEND    0x1018  //1 byte lcd queue end index
#define LCDQUEUE  0x1019  //256 bytes lcd queue
#define LCDQUEEND 0x1119  //end of the lcd stack
#define TIMER1    0x111a  //timer 1 fired
#define TIMER2    0x111b  //timer 2 fired
#define TM1VAL    0x111c  //2 bytes (int) - timer 1 value
#define TM1HIGH   0x111d  //high byte of time 1 value
#define TM2VAL    0x111e  //2 bytes (int) - timer 2 value
#define TM2HIGH   0x111f  //high byte of time 2 value
#define PLAY1POS  0x1120  //player 1 position, 1 byte
#define PLAY2POS  0x1121  //player 2 position, 1 byte
#define PLAY1LF   0x1122  //player 1 life, 1 byte
#define PLAY2LF   0x1123  //player 2 life, byte
#define STAGE_CT  0x1124  //state transition counter, 1 byte
#define STAGE     0x1125  //current state, 1 byte
#define CTRL1     0x1126  //controller 1 state, 1 byte
#define CTRL2     0x1127  //controller 2 state, 1 byte
#define PLAY1JP   0x1128  //player 1 jumping, 1 byte
#define PLAY2JP   0x1129  //player 2 jumping, 1 byte


void set_timer_1(unsigned int tm) {
    *(unsigned int*)TM1VAL = tm;
    *(unsigned int*)T1CL = *(unsigned char*)TM1VAL;
    *(unsigned int*)T1CH = *(unsigned char*)TM1HIGH;
}

void set_timer_2(unsigned int tm) {
    *(unsigned int*)TM2VAL = tm;
    *(unsigned int*)T2CL = *(unsigned char*)TM2VAL;
    *(unsigned int*)T2CH = *(unsigned char*)TM2HIGH;
}

//check if lcd is ready
unsigned char lcd_busy() {
     unsigned char busy = 0x08;
    
    *(unsigned char*)DDRA = 0xf7;  //set PORTA to high output
                                   // low input
    *(unsigned char*)PORTA = LCD_R; // set Read
    *(unsigned char*)PORTA = LCD_R|LCD_E; // set Read and E
    busy = *(unsigned char*)PORTA; //read busy flag from PORTA
    *(unsigned char*)PORTA = LCD_R; // set Read and E
    *(unsigned char*)PORTA = LCD_R|LCD_E; // set Read and E
    
    *(unsigned char*)PORTA = LCD_R; // set Read
    *(unsigned char*)DDRA = 0xff;  //set PORTA output
    return busy&LCD_BUSY;
}

void send_lcd_instruction(unsigned char ins, unsigned char single)
{
    unsigned char send = ins&HIGH;
     send = send>>4;
    *(unsigned char*)PORTA = send;
    *(unsigned char*)PORTA = send|LCD_E;
    *(unsigned char*)PORTA = send;  //clear flags
    if (single == 0x00) {
        send = ins&LOW;
        *(unsigned char*)PORTA = send;
        *(unsigned char*)PORTA = send|LCD_E;
        *(unsigned char*)PORTA = send;  //clear flags
    }
    
}

void send_lcd_char(unsigned char c) {
    unsigned char send = c&HIGH;
    
    send = send>>4;
    send = send|LCD_RS;
    *(unsigned char*)PORTA = send;
    *(unsigned char*)PORTA = send|LCD_E;
    *(unsigned char*)PORTA = send;

    send = c&LOW;
    send = send|LCD_RS;
    *(unsigned char*)PORTA = send;
    *(unsigned char*)PORTA = send|LCD_E;
    *(unsigned char*)PORTA = send;
}

unsigned char check_lcd_send();

void lcd_print_char_async(unsigned char c)
{
    unsigned int ptr;
    unsigned char idx;
    ptr = LCDQUEUE;
    idx = *(unsigned char*)QUEEND;
    ptr += idx;
    *(unsigned char*)ptr = c;
    ++ptr;
    ++idx;
    *(unsigned char*)ptr = 0x02;
    if(ptr == LCDQUEEND) {
        idx = 0;
    } else {
        ++idx;
    }
    *(unsigned char*)QUEEND = idx;
    check_lcd_send();
}

void lcd_send_instruction_async(unsigned char ins, unsigned char single)
{
    unsigned int ptr;
    unsigned char idx;
    ptr = LCDQUEUE;
    idx = *(unsigned char*)QUEEND;
    ptr += idx;
    *(unsigned char*)ptr = ins;
    ++ptr;
    ++idx;
    *(unsigned char*)ptr = single;
    if(ptr == LCDQUEEND) {
        idx = 0;
    } else {
        ++idx;
    }
    *(unsigned char*)QUEEND = idx;
    check_lcd_send();
}

unsigned char check_lcd_send() {
    unsigned char type;
    unsigned char ins;
    unsigned int ptr;
    unsigned char idx = *(unsigned char*)QUESTART;
    if (idx == *(unsigned char*)QUEEND) {
        return 0x00;  //nothing to do
    }
    if(!lcd_busy()) {
        ptr = LCDQUEUE;
        ptr += idx;
        ins = *(unsigned char*)ptr;
        ++ptr;
        ++idx;
        type = *(unsigned char*)ptr;
        if (ptr == LCDQUEEND){
             idx = 0;
        } else {
            ++idx;
        }
        *(unsigned char*)QUESTART = idx;
        if(type == 0x02) {
            send_lcd_char(ins);
        } else {
            send_lcd_instruction(ins, type);
        }
        return 0x01;  //sent
    }
   return 0x02;  //not ready
}

void print_byte(unsigned char b) {
    unsigned char i = b&HIGH;
    
    i = i>>4;
    if (i < 0x0a) {
        lcd_print_char_async('0' + i);
    } else {
        i-=0x0a;
        lcd_print_char_async('a' + i);
    }
    i = b&LOW;
     if (i < 0x0a) {
        lcd_print_char_async('0' + i);
    } else {
        i-=0x0a;
        lcd_print_char_async('a' + i);
    }
}

void print_nes(unsigned char b) {
    unsigned char i = 0;
    if (b&0x80) {
        lcd_print_char_async('A');
    }
    else {
        lcd_print_char_async(' ');
    }
    if (b&0x40) {
        lcd_print_char_async('B');
    }
    else {
        lcd_print_char_async(' ');
    }
    if (b&0x20) {
        lcd_print_char_async('s');
    }
    else {
        lcd_print_char_async(' ');
    }
    if (b&0x10) {
        lcd_print_char_async('S');
    }
    else {
        lcd_print_char_async(' ');
    }
    if (b&0x08) {
        lcd_print_char_async('U');
    } 
    else {
        lcd_print_char_async(' ');
    }
    if (b&0x04) {
        lcd_print_char_async('D');
    }
    else {
        lcd_print_char_async(' ');
    }
    if (b&0x02) {
        lcd_print_char_async('L');
    }
    else {
        lcd_print_char_async(' ');
    }
    if (b&0x01) {
        lcd_print_char_async('R');
    }
    else {
        lcd_print_char_async(' ');
    }
}

void print_string(const unsigned char * str)
{
    while(*str != 0) {
        lcd_print_char_async(*str);
        ++str;
    }
}

void load_custom_characters() {
    lcd_send_instruction_async(0x40, 0);  //set CGRAM address 0
    lcd_print_char_async(0x1c); //player 1 stand
    lcd_print_char_async(0x14);
    lcd_print_char_async(0x1c);
    lcd_print_char_async(0x08);
    lcd_print_char_async(0x0c);
    lcd_print_char_async(0x08);
    lcd_print_char_async(0x14);
    lcd_print_char_async(0x14);
    lcd_send_instruction_async(0x48, 0);  //set CGRAM address 1
    lcd_print_char_async(0x00); //player 1 squat
    lcd_print_char_async(0x1c); 
    lcd_print_char_async(0x14);
    lcd_print_char_async(0x1c);
    lcd_print_char_async(0x08);
    lcd_print_char_async(0x0c);
    lcd_print_char_async(0x08);
    lcd_print_char_async(0x14);
    lcd_send_instruction_async(0x50, 0);  //set CGRAM address 2
    lcd_print_char_async(0x0e); //player 1 punch
    lcd_print_char_async(0x0a);
    lcd_print_char_async(0x0e);
    lcd_print_char_async(0x04);
    lcd_print_char_async(0x07);
    lcd_print_char_async(0x04);
    lcd_print_char_async(0x0a);
    lcd_print_char_async(0x0a);
    lcd_send_instruction_async(0x58, 0);  //set CGRAM address 3
    lcd_print_char_async(0x0e); //player 1 kick
    lcd_print_char_async(0x0a);
    lcd_print_char_async(0x0e);
    lcd_print_char_async(0x04);
    lcd_print_char_async(0x0c);
    lcd_print_char_async(0x07);
    lcd_print_char_async(0x08);
    lcd_print_char_async(0x08);
    lcd_send_instruction_async(0x60, 0);  //set CGRAM address 4
    lcd_print_char_async(0x07); //player 2 stand
    lcd_print_char_async(0x05);
    lcd_print_char_async(0x07);
    lcd_print_char_async(0x02);
    lcd_print_char_async(0x06);
    lcd_print_char_async(0x02);
    lcd_print_char_async(0x05);
    lcd_print_char_async(0x05);
    lcd_send_instruction_async(0x68, 0);  //set CGRAM address 5
    lcd_print_char_async(0x00); //player 2 squat
    lcd_print_char_async(0x07); 
    lcd_print_char_async(0x05);
    lcd_print_char_async(0x07);
    lcd_print_char_async(0x02);
    lcd_print_char_async(0x06);
    lcd_print_char_async(0x02);
    lcd_print_char_async(0x05);
    lcd_send_instruction_async(0x70, 0);  //set CGRAM address 6
    lcd_print_char_async(0x0e); //player 2 punch
    lcd_print_char_async(0x0a); 
    lcd_print_char_async(0x0e);
    lcd_print_char_async(0x04);
    lcd_print_char_async(0x1c);
    lcd_print_char_async(0x04);
    lcd_print_char_async(0x0a);
    lcd_print_char_async(0x0a);
    lcd_send_instruction_async(0x78, 0);  //set CGRAM address 6
    lcd_print_char_async(0x0e); //player 2 kick
    lcd_print_char_async(0x0a); 
    lcd_print_char_async(0x0e);
    lcd_print_char_async(0x04);
    lcd_print_char_async(0x06);
    lcd_print_char_async(0x1c);
    lcd_print_char_async(0x02);
    lcd_print_char_async(0x02);
}

unsigned char get_controllers() {
    unsigned char nes_current1 = 0x00;
    unsigned char nes_current2 = 0x00;
    unsigned char nes_read = 0x00;
    unsigned char idx = 0x00;
    unsigned char nes_changed = 0x00;
    *(unsigned char*)PORTB = 0x08; //NES set latch high
    *(unsigned char*)TIMER1 = 0x00;
    {asm nop;}  //give latch some time
    {asm nop;}
    {asm nop;}
    *(unsigned char*)PORTB = 0x00; //NES set latch low

    //now read first bits
    nes_read = *(unsigned char*)PORTB;
    
    if (nes_read&0x01) {
        nes_current1 = nes_current1<<1;
        
    } else {
        nes_current1 = nes_current1<<1;
        ++nes_current1;
    }
    nes_read = nes_read>>1;
    
    if(nes_read&0x01) {
        nes_current2 = nes_current2<<1;
    } else {
        nes_current2 = nes_current2<<1;
        ++nes_current2;
    }
    //pulse the clock
    *(unsigned char*)PORTB = 0x04; //NES set clock high
    {asm nop;}
    {asm nop;}
    {asm nop;}
    *(unsigned char*)PORTB = 0x00; //NES set clock low

    for(idx = 0x00; idx < 0x07;++idx){
        nes_read = *(unsigned char*)PORTB;
        
        if (nes_read&0x01) {
            nes_current1 = nes_current1<<1;
        } else {
            nes_current1 = nes_current1<<1;
            ++nes_current1;
        }
        nes_read = nes_read>>1;
        
        if(nes_read&0x01) {
            nes_current2 = nes_current2<<1;
        } else {
            nes_current2 = nes_current2<<1;
            ++nes_current2;
        }
        //pulse the clock again
        *(unsigned char*)PORTB = 0x04; //NES set clock high
        {asm nop;}
        {asm nop;}
        {asm nop;}
        *(unsigned char*)PORTB = 0x00; //NES set clock low
    }
    if (*(unsigned char*)CTRL1 != nes_current1) {
        nes_changed = 0x01;
        *(unsigned char*)CTRL1 = nes_current1;
    }
      if (*(unsigned char*)CTRL2 != nes_current2) {
        nes_changed = 0x01;
        *(unsigned char*)CTRL2 = nes_current2;
    }
    return nes_changed;
    
}

void switch_to_round(unsigned char rd) {
    *(unsigned char*)PLAY1POS = LEFT_MOST;
    *(unsigned char*)PLAY2POS = RIGHT_MOST;
    *(signed char*)PLAY1LF = 0x64;
    *(signed char*)PLAY2LF = 0x64;
    lcd_send_instruction_async(0x01, 0x00);  //clear the screen
    lcd_send_instruction_async(0x02, 0);  //set display to home
    print_string("    ROUND ");
    lcd_print_char_async('0' + rd);
    print_string("     ");
    *(unsigned char*)STAGE_CT = 0x28;
}

unsigned char check_fight_over() {
    if (*(signed char*)PLAY1LF <= 0x00 || *(signed char*)PLAY2LF <= 0x00) {
        if (*(unsigned char*)STAGE == GAME_RD1F) {
            *(unsigned char*)STAGE = GAME_RD2;
            switch_to_round(0x02);
            return 0x01;
        }
        else if(*(unsigned char*)STAGE == GAME_RD2F) {
            *(unsigned char*)STAGE = GAME_RD3;
            switch_to_round(0x03);
            return 0x01;
        }
        else {
            *(unsigned char*)STAGE = GAME_START;
            lcd_send_instruction_async(0x01, 0x00);  //clear the screen
            lcd_send_instruction_async(0x02, 0x00);  //set display to home
            print_string("      START     ");
            *(unsigned char*)STAGE_CT = 0x28;
            return 0x01;
        }
    }
    return 0x00;
}

unsigned char apply_hits() {
    unsigned char hits = 0x00;
    // can't hit if either is jumping
    if (*(unsigned char*)PLAY1JP || *(unsigned char*)PLAY2JP) {
        return hits;  
    }

    // are they right next to each other
    if (*(unsigned char*)PLAY1POS == (*(unsigned char*)PLAY2POS - 0x01)) {
        if(*(unsigned char*)CTRL1&NES_A) {
            if(*(unsigned char*)CTRL2&NES_A) {  //both punching knock back
                if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
                    --(*(unsigned char*)PLAY1POS);
                }
                if (*(unsigned char*)PLAY2POS != RIGHT_MOST) {
                    ++(*(unsigned char*)PLAY2POS);
                }
                hits = 0x01;
            }
            else {  //P2 kicking or doing nothing,  gets hit
                if (*(unsigned char*)PLAY2POS != RIGHT_MOST) {
                    ++(*(unsigned char*)PLAY2POS);
                }
                (*(char*)PLAY2LF)-=0x0a;
                hits = 0x01;
            }
        }
        else if(*(unsigned char*)CTRL1&NES_B) {  //player 1 kicking
            if(*(unsigned char*)CTRL2&NES_A) {  //player 2 punching hits 1
                if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
                    --(*(unsigned char*)PLAY1POS);
                }
                (*(signed char*)PLAY1LF)-=0x01;
                hits = 0x01;
            }
            else if(*(unsigned char*)CTRL2&NES_B) {  //both kicking,  knock back
                if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
                    --(*(unsigned char*)PLAY1POS);
                }
                if (*(unsigned char*)PLAY2POS != RIGHT_MOST) {
                    ++(*(unsigned char*)PLAY2POS);
                }
                hits = 0x01;
            } else {  //player 2 doing nothing, gets hit
                if (*(unsigned char*)PLAY2POS != RIGHT_MOST) {
                    ++(*(unsigned char*)PLAY2POS);
                }
                (*(char*)PLAY2LF)-=(char)0x0f;
                hits = 0x01;
            }
        } else if(*(unsigned char*)CTRL2&NES_A) {  //player 2 punching hits 1
            if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
                --(*(unsigned char*)PLAY1POS);
            }
            (*(signed char*)PLAY1LF)-=0x0a;
            hits = 0x01;
        } else if(*(unsigned char*)CTRL2&NES_B) {  //player 2 kicking hits 1
            if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
                --(*(unsigned char*)PLAY1POS);
            }
            (*(signed char*)PLAY1LF)-=0x0f;
            hits = 0x01;
        }
    }
    return hits;
}

void draw_power() {
    char i = 0;
    char pow = 0;
    for(i = 0; i < 5; ++i) {
        pow += 20;
        if (*(char*)PLAY1LF >= pow) {
            lcd_print_char_async(0xdb);
        } else if (*(char*)PLAY1LF >= (pow - 10)){
            lcd_print_char_async(0xa1);
        }
    }
    lcd_send_instruction_async(0x8b, 0x00);  //set mid through first line
    pow = 100;
     for(i = 0; i < 5; ++i) {
        
        if (*(char*)PLAY2LF >= pow) {
            lcd_print_char_async(0xdb);
        } else if (*(char*)PLAY2LF >= (pow - 10)){
            lcd_print_char_async(0xa1);
        } else {
            lcd_print_char_async(' ');
        }
        pow -= 20;
        
    }
}

void draw_scene() {
    unsigned char p1_sprite = P1_STAND;
    unsigned char p2_sprite = P2_STAND;
    unsigned char ctrl1 = *(unsigned char*)CTRL1;
    unsigned char ctrl2 = *(unsigned char*)CTRL2;
    lcd_send_instruction_async(0x01, 0x00);  //clear the screen
    draw_power();
    if (*(unsigned char*)PLAY1JP == 0x00) {
       
        if (ctrl1&NES_UP) {
            *(unsigned char*)PLAY1POS = *(unsigned char*)PLAY1POS - 0x40;
            *(unsigned char*)PLAY1JP = 0x05;
        } 
        else {
            if(ctrl1&NES_LEFT) {
                if (*(unsigned char*)PLAY1POS != LEFT_MOST) {
                    --(*(unsigned char*)PLAY1POS);
                }
            }
            if(ctrl1&NES_RIGHT) {
                if (*(unsigned char*)PLAY1POS != RIGHT_MOST) {
                    ++(*(unsigned char*)PLAY1POS);
                }
            }

            if(ctrl1&NES_A) {
                p1_sprite = P1_PUNCH;
            } else if (ctrl1&NES_B) {
                p1_sprite = P1_KICK;
            }
        }

    }
    else {
        --(*(unsigned char*)PLAY1JP);
        if (*(unsigned char*)PLAY1JP == 0x00) {
            *(unsigned char*)PLAY1POS = *(unsigned char*)PLAY1POS + 0x40;
        }
    }

    if (*(unsigned char*)PLAY2JP == 0x00) {
       
        if (ctrl2&NES_UP) {
            *(unsigned char*)PLAY2POS = *(unsigned char*)PLAY2POS - 0x40;
            *(unsigned char*)PLAY2JP = 0x05;
        } 
        else {
             if(ctrl2&NES_LEFT) {
                if (*(unsigned char*)PLAY2POS != LEFT_MOST) {
                    --(*(unsigned char*)PLAY2POS);
                }
            }
            if(ctrl2&NES_RIGHT) {
                if (*(unsigned char*)PLAY2POS != RIGHT_MOST) {
                    ++(*(unsigned char*)PLAY2POS);
                }
            }
            if(ctrl2&NES_A) {
                p2_sprite = P2_PUNCH;
            } else if (ctrl2&NES_B) {
                p2_sprite = P2_KICK;
            }
        }
    } else {
        --(*(unsigned char*)PLAY2JP);
        if (*(unsigned char*)PLAY2JP == 0x00) {
            
            *(unsigned char*)PLAY2POS = *(unsigned char*)PLAY2POS + 0x40;
        }
    }

    if ((*(unsigned char*)PLAY1POS&0x0f) >= (*(unsigned char*)PLAY2POS&0x0f)) {  //at same spot
        if(ctrl1&NES_RIGHT) {  //if player 1 moved right move back
            --(*(unsigned char*)PLAY1POS);
        }
        if(ctrl2&NES_LEFT){ //if player 2 moved left move back
            ++(*(unsigned char*)PLAY2POS);
        }
        
    }

    lcd_send_instruction_async(0x80|*(unsigned char*)PLAY1POS, 0x00);
    lcd_print_char_async(p1_sprite);
    lcd_send_instruction_async(0x80|*(unsigned char*)PLAY2POS, 0x00);
    lcd_print_char_async(p2_sprite);
}



void main() {
    unsigned char last_shift;
    unsigned char last_counter;
    unsigned char last_hits;
    unsigned char nes_changed;
    *(unsigned char*)IERG = 0xf2;  //set CA1 AND CB1 Interrupt enable
    *(unsigned char*)PCRG = 0x00;  //set CA's to active edge low
    
    *(unsigned char*)ACRG = 0x0c; //set shift in ACRG
    *(unsigned char*)DDRA = 0xef;  //set PORTA output - except last pin of first nibble
    *(unsigned char*)DDRB = 0x0c;  //set PORTB output on last 2 pins of first nibble, others input
    *(unsigned char*)SHIFT = 0x00;
    *(unsigned char*)KEYCODE = 0x00;
    *(unsigned char*)COUNTER = 0;
    *(unsigned char*)TIMER1 = 0x00;
    *(unsigned char*)TIMER2 = 0x00;
    *(unsigned char*)CTRL1 = 0x00;
    *(unsigned char*)CTRL2 = 0x00;
    *(unsigned char*)PLAY1JP = 0x00;
    *(unsigned char*)PLAY2JP = 0x00;
    last_counter = 0;
    last_shift = 0x00;
    last_hits = 0x01;  //set to 1 so that you force redraw
    *(unsigned char*)QUESTART = 0x00;
    *(unsigned char*)QUEEND = 0x00;

    lcd_send_instruction_async(0x20, 0x01);  //set 4 bit mode
    lcd_send_instruction_async(0x28, 0x00);  //set 4 bit mode, 2 lines
    load_custom_characters();
    lcd_send_instruction_async(0x0c, 0x00);  // turn on display
    
    lcd_send_instruction_async(0x06, 0x00);  //increment and shift cursor

    lcd_send_instruction_async(0x02, 0);  //set display to home
    *(unsigned char*)STAGE = GAME_START;
    *(unsigned char*)STAGE_CT = 0x28;
    print_string("      START     ");

    //flush all the sends
    while(check_lcd_send()) {}


    //done with startup
    set_timer_2(0xffff);  //50ms
    while(1) {
        //see if we can drain the lcd stack
        check_lcd_send();
        if(*(unsigned char*)TIMER2){
            if (*(unsigned char*)STAGE == GAME_START || 
            *(unsigned char*)STAGE == GAME_RD1 ||
            *(unsigned char*)STAGE == GAME_RD2 ||
            *(unsigned char*)STAGE == GAME_RD3 ) {
                --(*(unsigned char*)STAGE_CT);
                  // going from start of state
                if (*(unsigned char*)STAGE_CT == 0x00) {
                    if (*(unsigned char*)STAGE == GAME_START) {
                        *(unsigned char*)STAGE = GAME_RD1;
                        switch_to_round(0x01);
                    } else if (*(unsigned char*)STAGE == GAME_RD1) {
                        *(unsigned char*)STAGE = GAME_RD1F;
                        last_hits = 0x01;
                    } else if (*(unsigned char*)STAGE == GAME_RD2) {
                        *(unsigned char*)STAGE = GAME_RD2F;
                        last_hits = 0x01;
                    } else if (*(unsigned char*)STAGE == GAME_RD3) {
                        *(unsigned char*)STAGE = GAME_RD3F;
                        last_hits = 0x01;
                    }

                }
            } else {
                nes_changed = get_controllers();
                if(check_fight_over() == 0x00) {
                    //if nothing pressed and no one is jumping nothing to do
                    if(nes_changed|last_hits|*(unsigned char*)PLAY1JP|*(unsigned char*)PLAY2JP) {
                        draw_scene();
                        last_hits = apply_hits();
                    }
                }
            }
            set_timer_2(0xffff);
            *(unsigned char*)TIMER2 = 0x00;
        }
        
    }
}