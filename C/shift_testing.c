#define USING_02 1
#include "INTRINS.H"
 // W65C22S registers 
#define PORTB 0x6000  // in/out PortB
#define PORTA 0x6001  // in/out PortA
#define DDRB  0x6002  // Data Direction PortB
#define DDRA  0x6003  // Data Direction PortA
#define T1CL  0x6004  // Timer 1 low order counter
#define TICH  0x6005  // Timer 1 high order counter
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

#define RAM_START 0x1000 
#define COUNTER   0x1000 // 2 byte counter
#define SHIFT     0x1002 // 1 byte shift counter
#define MESSAGE   0x1004  //16 bytes
#define SERIAL    0x1014  //1 byte
#define ASKWORK   0x1015  //1 byte
#define LSTIRQ    0x1016


void lcd_wait() {
    unsigned char busy = 0x08;
    
    *(unsigned char*)DDRA = 0xf7;  //set PORTA to high output
                                   // low input
    
    while(busy&LCD_BUSY){
        *(unsigned char*)PORTA = LCD_R; // set Read
        *(unsigned char*)PORTA = LCD_R|LCD_E; // set Read and E
        busy = *(unsigned char*)PORTA; //read busy flag from PORTA
        *(unsigned char*)PORTA = LCD_R; // set Read and E
        *(unsigned char*)PORTA = LCD_R|LCD_E; // set Read and E
    }
    *(unsigned char*)PORTA = LCD_R; // set Read
    *(char*)DDRA = 0xff;  //set PORTA output
}

void lcd_instruction(unsigned char ins, short single)
{
    unsigned char send = ins&HIGH;
    lcd_wait();
    
    send = send>>4;
    *(unsigned char*)PORTA = send;
    *(unsigned char*)PORTA = send|LCD_E;
    *(unsigned char*)PORTA = send;  //clear flags
    if (single == 0) {
        send = ins&LOW;
        *(unsigned char*)PORTA = send;
        *(unsigned char*)PORTA = send|LCD_E;
        *(unsigned char*)PORTA = send;  //clear flags
    }
}

void print_char(unsigned char c) {
    unsigned char send = c&HIGH;
    lcd_wait();
    
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

void print_byte(unsigned char b) {
    unsigned char i = 0;
    for(i; i < 0x08; i++) {
        if (b&0x80) {
            print_char('1');
        } else {
            print_char('0');
        }
        b = b << 1;
    }
}

void print_string(const unsigned char * str)
{
    while(*str != 0) {
        print_char(*str);
        ++str;
    }
}

void main() {
    unsigned char shift_reg;
    *(unsigned char*)IERG = 0x92;  //set CA1 AND CB1 Interrupt enable
    *(unsigned char*)PCRG = 0x00;  //set CA's to active edge low
    
    *(unsigned char*)ACRG = 0x0c; //set shift in ACRG
    *(char*)DDRA = 0xef;  //set PORTA output - except last pin of first nibble
    *(char*)DDRB = 0x00;  //set PORTB input
    *(unsigned char*)SHIFT = 0x00;
    *(unsigned char*)LSTIRQ = 0x00;
    *(unsigned int*)COUNTER = 0;
    shift_reg = 0x00;


    lcd_instruction(0x20, 1);  //set 4 bit mode
    lcd_instruction(0x28, 0);  //set 4 bit mode, 2 lines
    lcd_instruction(0x0e, 0);  // turn on display
    lcd_instruction(0x06, 0);  //increment and shift cursor
   
    while(1) {
        
        if(*(unsigned char*)SHIFT == 0x09) {
            
            *(unsigned char*)SHIFT = 0x00;
        }
        shift_reg = *(unsigned char*)SHRG;
        lcd_instruction(0x02, 0);  //set display to home
        print_string("SHIFT ");
        print_char('0' + *(unsigned char*)SHIFT);
        print_char(' ');
        print_byte(shift_reg);
        lcd_instruction(0xc0, 0);  //set to second line
        print_string("COUNTER ");
        print_byte(*(unsigned char*)COUNTER);
    }
}