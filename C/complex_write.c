#define USING_02 1
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

 // LCD register bits
#define LCD_E     0x80  // Enable
#define LCD_RW    0x40  // Read/Write
#define LCD_RS    0x20  // Select

#define RAM_START 0x1000 
#define COUNTER   RAM_START+0

void lcd_wait() {
    unsigned char busy = 0x80;
    
    *(unsigned char*)DDRB = 0x00;  //set PORTB input
    
    while(busy & 0x80){
        *(unsigned char*)PORTA = LCD_RW; // set RW
        *(unsigned char*)PORTA = LCD_RW|LCD_E; // set RW and E
        busy = *(unsigned char*)PORTB; //read busy flag from port b
    }
    *(unsigned char*)PORTA = LCD_RW; // set RW
    *(char*)DDRB = 0xff;  //set PORTB output
}

void lcd_instruction(unsigned char ins)
{
    lcd_wait();
    *(unsigned char*)PORTB = ins;  // send instruction
    *(unsigned char*)PORTA = 0x00;  // clear flags
    *(unsigned char*)PORTA = LCD_E; // set enabled flag
    *(unsigned char*)PORTA = 0x00; //clear flags
}

void print_char(unsigned char c) {
    lcd_wait();
    *(unsigned char*)PORTB = c;
    *(unsigned char*)PORTA = LCD_RS;
    *(unsigned char*)PORTA = LCD_RS|LCD_E;
    *(unsigned char*)PORTA = LCD_RS;
}

void print_string(const unsigned char * str)
{
    while(*str != 0) {
        print_char(*str);
        ++str;
    }
}

void main() {
    *(char*)DDRB = 0xff;  //set PORTB output
    *(char*)DDRA = 0xe0;  //set first 3 pins of PORTA output

    lcd_instruction(0x38);  //set 8 bit mode, 2 lines
    lcd_instruction(0x0e);  // turn on display
    lcd_instruction(0x06);  //increment and shift cursor

    print_string("HEY JOHN");
    while(1) {}
}