.equ CPU_CLOCK = 8000000 ; clock in Hz (part CSTCE8M00G52A-R0)
.equ RACKET_SPEED = 8 ; the greater the value, the slower
; "speed"-  number of ms, between jumping for one pixel
.equ RACKET_SIZE = 16;  inchangeable
.equ DISPLAY_Y_SIZE = 64
.equ DISPLAY_X_SIZE = 128
.equ RACKET_X_SIZE =  2 ; inchangeable
.equ RACKET_FROM_END = 4
.equ BALL_STARTING_SPEED_X = 20 ; range from 1-127
.equ BALL_STARTING_SPEED_Y = 39 ; range from 1-127 the same rules as for every other "speed"
.equ BALL_Y_SPEED_STEP = 4
;.equ BALL_X_SPEED_STEP = 2 unsed
.equ BALL_SIZE = 2 ;  inchangeable
; x [ms], for pixel
; --------LCD  D/#C --------
; D/#C 
.equ PORT_LCD_DC = PORTB
.equ DDR_LCD_DC  = DDRB
.equ PIN_LCD_DC  = PINB
.equ IN_LCD_DC   = PINB0

; ---------LCD  RST ---------
; Reset
.equ PORT_LCD_RST = PORTB
.equ DDR_LCD_RST  = DDRB
.equ PIN_LCD_RST  = PINB
.equ IN_LCD_RST   = PINB1

; -------- RF input --------
; as player 2 DOWN button
.equ PORT_P2_DOWN = PORTC
.equ DDR_P2_DOWN  = DDRC
.equ PIN_P2_DOWN  = PINC
.equ IN_P2_DOWN   = PINC3

; ------- RF SHUT ---------
; as player 2 UP button

.equ PORT_P2_UP = PORTC
.equ DDR_P2_UP  = DDRC
.equ PIN_P2_UP  = PINC
.equ IN_P2_UP   = PINC2

; ------- UART --------
; RX as player 1 DOWN button
.equ PORT_P1_DOWN = PORTD
.equ DDR_P1_DOWN  = DDRD
.equ PIN_P1_DOWN  = PIND
.equ IN_P1_DOWN   = PIND0

; TX as player 1 UP button
.equ PORT_P1_UP = PORTD
.equ DDR_P1_UP  = DDRD
.equ PIN_P1_UP  = PIND
.equ IN_P1_UP   = PIND1

; ------- Iaux -------- 
; as START button
.equ PORT_START = PORTC
.equ DDR_START  = DDRC
.equ PIN_START  = PINC
.equ IN_START   = PINC0

;******************************************************************************
; Register Definitions
;******************************************************************************

.def productL  =     R0         ; reserved, uses by command mul /Product LOW
.def productH  =     R1         ; reserved, uses by command mul /Product HIGH
.def zero      =     R2
.def one       =     R3
.def ff        =     R4
.def timer_2   =     R5         ; system timer MSB
.def timer_1   =     R6         ; system timer
.def timer_0   =     R7         ; system timer LSB
.def rackettimer = R8         
.def ballspeedX= R9         
.def ballspeedY   =     R10        
.def sreg_save =     R11       
.def balltimerX =   R12
.def balltimerY =   R13
;.def     =     R14  
.def counter = R15

.def param     =     R16
.def param1    =     R17
.def param2    =     R18
.def param3    =     R19
.def param4    =     R20
.def param5    =     R21
.def param6    =     R22
;.def param7    =     R23
.def flagsBall    =     R23
	.equ F_TICK_X=		0
	.equ F_TICK_Y=		1
	.equ F_BALL_LEFT =	2
	.equ F_BALL_UP=		3 

.def tmp =     R24

.def flags     =     R25
 .equ    F_TICK          = 0    ; set every 16 ms
 .equ    F_P1_UP         = 1    ; set if pressed
 .equ    F_P1_DOWN       = 2
 .equ    F_P2_UP         = 3    ; 
 .equ    F_P2_DOWN       = 4
 .equ    F_START         = 5    ; 
 .equ	 F_GAME			 = 6	;
 


;.def	XL	= r26		; X pointer low
;.def	XH	= r27		; X pointer high
;.def	YL	= r28		; 
;.def	YH	= r29		; 
;.def	ZL	= r30		; 
;.def	ZH	= r31		;


;******************************************************************************
;; Interrupts table
;******************************************************************************
.cseg
.org    0x0000              ; RESET External Pin, Power-on Reset, Brown-out Reset, Watchdog Reset, and JTAG AVR Reset
        rjmp   start		; Reset handler 0000

.org    0x0002              ; INT0 External Interrupt Request 0
        rjmp    _unused_

.org    0x0004              ; INT1 External Interrupt Request 1
        rjmp    _unused_

.org    0x0006
        rjmp    _unused_	; PCINT0 Pin Change Interrupt Request 0

.org    0x0008
        rjmp    _unused_	; PCINT1 Pin Change Interrupt Request 1

.org    0x000A
        rjmp    _unused_	; PCINT2 Pin Change Interrupt Request 2

.org    0x000C
        rjmp    _unused_	; WDT Watchdog Time-out Interrupt

.org    0x000E              ; TIMER2 COMPA Timer/Counter2 Compare Match
        rjmp    _unused_    ; unused interrupt

.org    0x0010              ; TIMER2 COMPA Timer/Counter2 Compare Match
        rjmp    _unused_    ; unused interrupt

.org    0x0012              ; TIMER2 OVF Timer/Counter2 Overflow
        rjmp    _unused_

.org    0x0014              ; TIMER1 CAPT Timer/Counter1 Capture Event
        rjmp    _unused_    ;

.org    0x0016              ; TIMER1 COMPA Timer/Counter1 Compare Match A
        rjmp    _unused_    ; unused interrupt

.org    0x0018              ; TIMER1 COMPB Timer/Coutner1 Compare Match B
        rjmp    _unused_    ; unused interrupt

.org    0x001A              ; TIMER1 OVF Timer/Counter1 Overflow
        rjmp    _unused_

.org    0x001C              ; TIMER0 COMPA Timer/Counter0 Compare Match A
        rjmp    SystemTimerOvf

.org    0x001E              ; TIMER0 COMPB Timer/Counter0 Compare Match B
        rjmp    _unused_    ; unused interrupt

.org    0x0020              ; TIMER0 OVF Timer/Counter0 Overflow
        rjmp    _unused_    ; unused interrupt

.org    0x0022              ; SPI, STC SPI Serial Transfer Complete
        rjmp    _unused_    ; unused interrupt

.org    0x0024              ; USART, RX USART Rx Complete
        rjmp    _unused_

.org    0x0026              ; USART, UDRE USART, Data Register Empty
        rjmp    _unused_    ; unused interrupt

.org    0x0028              ; USART, TX USART, Tx Complete
        rjmp    _unused_

.org    0x002A               ; ADC ADC Conversion Complete
        rjmp    _unused_     ; unused interrupt

.org    0x002C              ; EE READY EEPROM Ready
        rjmp    _unused_    ; unused interrupt

.org    0x002E              ; ANALOG COMP Analog Comparator
        rjmp    _unused_    ; unused interrupt

.org    0x0030              ; TWI 2-wire Serial Interface
        rjmp    _unused_    ; unused interrupt

.org    0x0032              ; SPM READY Store Program Memory Ready
        rjmp    _unused_    ; unused interrupt

_unused_: reti 