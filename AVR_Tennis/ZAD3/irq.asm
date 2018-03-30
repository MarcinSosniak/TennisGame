.cseg

//*****************************************************************************
// System Timer
// 1ms
//*****************************************************************************
; Timer0
SystemTimerOvf:

    in      sreg_save, SREG

    push    param

    ; update system timer
    add     timer_0,one      ; LSB
    adc     timer_1,zero
    adc     timer_2,zero     ; MSB


    mov     param,timer_0
    andi    param,0x07
    cpi     param,0x07
    brne    SystemTimerOvfSkip
    ; check keys every 8 ms
    cbr     flags,(1<<F_P1_UP)|(1<<F_P1_DOWN)|(1<<F_P2_UP)|(1<<F_P2_DOWN)|(1<<F_START) ; clear all pins

    sbis    PIN_P2_DOWN,IN_P2_DOWN
    sbr     flags,(1<<F_P2_DOWN)

    sbis    PIN_P2_UP,IN_P2_UP
    sbr     flags,(1<<F_P2_UP)

    sbis    PIN_P1_DOWN,IN_P1_DOWN
    sbr     flags,(1<<F_P1_DOWN)

    sbis    PIN_P1_UP,IN_P1_UP
    sbr     flags,(1<<F_P1_UP)

    sbis    PIN_START,IN_START
    sbr     flags,(1<<F_START)

SystemTimerOvfSkip:
	cp		timer_0,rackettimer
	brne	SkipTimerSetTick
	ldi		param, RACKET_SPEED
	add		rackettimer,param
    sbr     flags,(1<<F_TICK) ; set tick flag
SkipTimerSetTick:

	cp timer_0, balltimerX
	brne SkipTimerBallXSetTick
	add balltimerX, ballspeedX
	sbr flagsBall, (1<<F_TICK_X)
SkipTimerBallXSetTick:

	cp timer_0, balltimerY
	brne SkipTimerBallYSetTick
	add balltimerY, ballspeedY
	sbr flagsBall, (1<<F_TICK_Y)
SkipTimerBallYSetTick:


    pop     param

    out     SREG, sreg_save

    reti
