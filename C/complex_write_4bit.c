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

#define HIGH  0xf0
#define LOW   0x0f

 // LCD register bits
#define LCD_E     0x80  // Enable
#define LCD_R     0x40  // Read -write is 0
#define LCD_RS    0x20  // register Select
#define LCD_BUSY  0x08  // busy flag

#define RAM_START 0x1000 
#define COUNTER   RAM_START+0

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

void print_string(const unsigned char * str)
{
    while(*str != 0) {
        print_char(*str);
        ++str;
    }
}

void main() {
    *(char*)DDRA = 0xff;  //set PORTB output
    *(char*)DDRB = 0x00;  //set first 3 pins of PORTA output
    lcd_instruction(0x20, 1);  //set 4 bit mode
    lcd_instruction(0x28, 0);  //set 4 bit mode, 2 lines
    lcd_instruction(0x0e, 0);  // turn on display
    lcd_instruction(0x06, 0);  //increment and shift cursor

    print_string("HEY JOHN");
    while(1) {}
}