;
; ZAD3.asm
;
; Created: 25.05.2017 19:53:26
; Author : MarcinS
;
; include
.include "Def.asm"

.dseg
rP1RacketPos: .Byte	1
rP2RacketPos: .Byte	1
rBallYPos: .Byte 1
rBallXPos: .Byte 1




.cseg
;BEGIN
start:
    ; Init Stack
    ldi     param, LOW(RAMEND)  ; LOW-Byte of upper RAM-Adress
    out     SPL, param
    ldi     param, HIGH(RAMEND) ; HIGH-Byte of upper RAM-Adress
    out     SPH, param

    ; init registers
    ldi     param,0
	
    mov     zero,param
	ldi     param,$FF
    mov     ff,param
    ldi     param,1
    mov     one,param
	; init game registers 
	
    mov     flags,zero

    ; clear RAM
    ldi     YL,LOW(0x100)
    ldi     YH,HIGH(0x100)
    ldi     param,LOW(0x2ff)
    ldi     param1,HIGH(0x2ff)
ClrRamLoop:
    st      Y+,zero
    cp      param,YL
    cpc     param1,YH
    brne    ClrRamLoop


    call    InitHardware
    call    InitLcd

	


    sei ; enable interupts, setting hardware is done
;; setting is done

;; prepare before first game, and await start
	ldi		param, (((DISPLAY_Y_SIZE-RACKET_SIZE)/2) -1) ; set racket to center 
	sts		rP1RacketPos,param
	sts		rP2RacketPos,param

	lds		param1, rP2RacketPos
	ldi		param2, DISPLAY_X_SIZE-RACKET_FROM_END - RACKET_X_SIZE
	rcall	DisplayRacket

	lds		param1, rP1RacketPos
	ldi		param2, RACKET_FROM_END
	rcall	DisplayRacket

	ldi		param1, (((DISPLAY_Y_SIZE-BALL_SIZE)/2) )
	sts		rBallYPos,param1
	ldi		param2,(((DISPLAY_X_SIZE-BALL_SIZE)/2) )
	sts		rBallYPos,param2
	rcall	DisplayBall
	
	rjmp	INFLOOP

;; main program;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MainProg:
	;; set game registers 
	clr		balltimerX
    clr		balltimerY
	clr		flagsBall
	clr		rackettimer
	ldi		param, BALL_STARTING_SPEED_X
	mov		ballspeedX, param
	ldi		param, BALL_STARTING_SPEED_Y
	mov		ballspeedY, param

	sbr		flags, (1<<F_GAME) ;; set game running

	ldi		param, (((DISPLAY_Y_SIZE-RACKET_SIZE)/2) -1) ; set racket to center 
	sts		rP1RacketPos,param
	sts		rP2RacketPos,param

	lds		param1, rP2RacketPos
	ldi		param2, DISPLAY_X_SIZE-RACKET_FROM_END - RACKET_X_SIZE
	rcall	DisplayRacket

	lds		param1, rP1RacketPos
	ldi		param2, RACKET_FROM_END
	rcall	DisplayRacket

	ldi		param1, (((DISPLAY_Y_SIZE-BALL_SIZE)/2) )
	sts		rBallYPos,param1
	ldi		param2,(((DISPLAY_X_SIZE-BALL_SIZE)/2) )
	sts		rBallYPos,param2
	rcall	DisplayBall

	;; prepare random ball direction
	cbr	 flagsBall, (1<<F_BALL_LEFT)
	sbrs timer_0, 4;
	sbr	 flagsBall, (1<<F_BALL_LEFT)

	cbr	 flagsBall, (1<<F_BALL_UP)
	sbrs timer_0, 5;
	sbr	 flagsBall, (1<<F_BALL_UP)

INFLOOPGAME: ;; current game loop
	rcall	CtrlRackets
	rcall	CtrlBall


	ldi param, BALL_STARTING_SPEED_X
	sbrc ballspeedX, 7 ; if it will go to the 255
	mov ballspeedX,param  ; set to beginning

	ldi param, BALL_STARTING_SPEED_Y
	sbrc ballspeedY, 7 ; if it will go to the 255
	mov ballspeedY,param  ; set to beginning


	sbrs	flags, F_GAME
	rjmp	INFLOOP 








	rjmp INFLOOPGAME


INFLOOP: ;;wait for game to start
	sbrs	flags, F_START
	rjmp	INFLOOP
	rcall ClearBall
	rjmp MainProg





































.include "hardware.asm"
.include "LCDcontrol.asm"
.include "irq.asm"
.include "Tennis.asm"



























