.cseg

InitHardware:
    ; ----------------------------------------------- PINS


    cbi     PORTB,PB2
    sbi     DDRB,PB2              ; #SS output. Must set as output form SPI Master mode

    sbi     PORTB,PB3
    sbi     DDRB,PB3              ; SPI MOSI

    ;sbi     PORTB,PB4
    ;sbi     DDRB,PB4              ; SPI MISO - doesn't work

    sbi     PORTB,PB5
    sbi     DDRB,PB5              ; SPI SCK

    sbi     PORT_LCD_DC,IN_LCD_DC
    sbi     DDR_LCD_DC,IN_LCD_DC              ; 

    cbi     PORT_LCD_RST,IN_LCD_RST
    sbi     DDR_LCD_RST,IN_LCD_RST           ; 



    ; inputs
    cbi     DDR_P2_DOWN,IN_P2_DOWN          ; as input with pull-up
    sbi     PORT_P2_DOWN,IN_P2_DOWN

    cbi     DDR_P2_UP,IN_P2_UP              ; as input with pull-up
    sbi     PORT_P2_UP,IN_P2_UP

    cbi     DDR_P1_DOWN,IN_P1_DOWN          ; as input with pull-up
    sbi     PORT_P1_DOWN,IN_P1_DOWN

    cbi     DDR_P1_UP,IN_P1_UP              ; as input with pull-up
    sbi     PORT_P1_UP,IN_P1_UP

    cbi     DDR_START,IN_START              ; as input with pull-up
    sbi     PORT_START,IN_START

    lds     param,MCUCR
    sbr     param,(1<<PUD)                  ; enable intrnal pull-ups
    sts     MCUCR,param

    ; ------------------------------------- TIMER0
    ; system clock
.equ TIMER_F = 1000 ;[Hz]
.equ N = 64 ; divider
.equ TIMER0_OCR = (CPU_CLOCK/(TIMER_F*N)) - 1 ; 1kHz


    ldi     param,TIMER0_OCR
    out     OCR0A,param
;   TCCR0A                              CTC , divider 64
;   +------+------+------+------+---+---+-----+-----+
;   |COM0A1|COM0A0|COM0B1|COM0B0| - | - |WGM01|WGM00|
;   +------+------+------+------+---+---+-----+-----+
;   |   0  |  0   |   0  |   0  | 0 | 0 |  1  |  0  | = 0x02
;   +------+------+------+------+---+---+-----+-----+

    ldi     param,(1<<WGM01)
    out     TCCR0A,param

;   TCCR0B
;   +------+------+------+------+-------+------+------+------+
;   |FOC0A |FOC0B |   -  |   -  | WGM02 | CS02 | CS01 | CS00 |
;   +------+------+------+------+-------+------+------+------+
;   |   0  |  0   |   0  |   0  |   0   |  0   |  1   |  1   | = 0x03
;   +------+------+------+------+-------+------+------+------+
    ldi     param,(1<<CS01)|(1<<CS00)
    out     TCCR0B,param

    lds     param,TIMSK0
    sbr     param,(1<<OCIE0A)     ; enable interrupt
    sts     TIMSK0,param


    ret

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------