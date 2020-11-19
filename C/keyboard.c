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
#define KEYCODE   0x1016  //1 byte
#define QUESTART  0x1017  //1 byte lcd queue start index
#define QUEEND    0x1018  //1 byte lcd queue end index
#define LCDQUEUE  0x1019  //256 bytes lcd queue
#define LCDQUEEND 0x1119  //end of the lcd stack

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
    *(char*)DDRA = 0xff;  //set PORTA output
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

void print_string(const unsigned char * str)
{
    while(*str != 0) {
        lcd_print_char_async(*str);
        ++str;
    }
}

void main() {
    unsigned char last_shift;
    unsigned char last_counter;
    *(unsigned char*)IERG = 0x92;  //set CA1 AND CB1 Interrupt enable
    *(unsigned char*)PCRG = 0x00;  //set CA's to active edge low
    
    *(unsigned char*)ACRG = 0x0c; //set shift in ACRG
    *(char*)DDRA = 0xef;  //set PORTA output - except last pin of first nibble
    *(char*)DDRB = 0x00;  //set PORTB input
    *(unsigned char*)SHIFT = 0x00;
    *(unsigned char*)KEYCODE = 0x00;
    *(unsigned int*)COUNTER = 0;
    last_counter = 0;
    last_shift = 0x00;
    *(unsigned int*)QUESTART = 0x00;
    *(unsigned int*)QUEEND = 0x00;

    lcd_send_instruction_async(0x20, 0x01);  //set 4 bit mode
    lcd_send_instruction_async(0x28, 0x00);  //set 4 bit mode, 2 lines
    lcd_send_instruction_async(0x0e, 0x00);  // turn on display
    lcd_send_instruction_async(0x06, 0x00);  //increment and shift cursor
    //flush all the sends
    while(check_lcd_send()) {}

    //done with startup
   
    while(1) {
        //see if we can drain the lcd stack
        check_lcd_send();
        if(*(unsigned char*)SHIFT != last_shift) {
            lcd_send_instruction_async(0x02, 0);  //set display to home
            print_string("SHIFT ");
            lcd_print_char_async('0' + *(unsigned char*)SHIFT);
            lcd_print_char_async(' ');
            print_byte(*(unsigned char*)SHRG);
            if(*(unsigned char*)SHIFT == 0x08) {
                *(unsigned char*)SHIFT = 0x00;
            }
            last_shift = *(unsigned char*)SHIFT;
        }
        if(*(unsigned char*)COUNTER != last_counter) {
            lcd_send_instruction_async(0xc0, 0);  //set to second line
            print_string("COUNTER ");
            print_byte(*(unsigned char*)COUNTER);
        }
    }
}