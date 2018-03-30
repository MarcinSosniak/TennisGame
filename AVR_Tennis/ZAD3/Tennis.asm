;---------------------------------------------------------------------------
; Display Racket	
; Parameters:
;	param, coutner,tmp	- destroyed
;   param1	- Y (bits) position (0 means touching high)
;   param2	- X (bits) position (generally 2 or 124)
;	param1	- has to be from 0 to 48; destroyed in process
;	param2	- has to be from 0 to 126; 
;---------------------------------------------------------------------------
DisplayRacket:
	
	; Set column start/end address
	; column adress is x position in bits
    ldi     param,0x21 ; command
    rcall   LcdCommand
    mov     param, param2 ; argument 1,  column begin
    rcall   LcdCommand
	mov     param, param2
	inc		param; the racket has 2 columns and so next column is end of column
    rcall   LcdCommand

    ; set page start/end adress
	; pages are vertical adresses
    ldi     param,0x22 ; command
    rcall   LcdCommand
    ldi     param,0xB0 ; only last 3 bist matter
    rcall   LcdCommand
    ldi     param,0xB7
    rcall   LcdCommand

	ldi		 param2,2
WriteLoopDR:
	cp		param2,zero
	breq	DisplayRacketEnd

	; target to write is set
	ldi		tmp,8
	mov		counter, tmp 
	mov		tmp, param1
	lsr		tmp
	lsr		tmp
	lsr		tmp ; now we have number of bytes to write 0s
	sub		counter, tmp ; remember how many bytes skipped
	mov		param,zero
	cp		tmp,zero 
	breq	AfterLoopDR
	
ZerosLoop:
	clr param
	rcall	LcdSendByte;
	dec		tmp;
	cpse	tmp, zero
	rjmp	ZerosLoop
AfterLoopDR:

	mov		param, ff 
	mov		tmp, param1
	andi	tmp, 0x07; 00000111 geting last 3 bits, 

ShiftLoop:
	cp		tmp,zero
	breq	ShiftLoopEnd
	lsl		param
	dec		tmp
	rjmp	ShiftLoop
ShiftLoopEnd:

	mov tmp, param ; save param
	rcall	LcdSendByte ; send the end 
	dec		counter
	mov		param,ff
	rcall	LcdSendByte
	dec		counter
	mov		param,tmp
	eor		param, ff ;; negate tm
	cp		counter, zero ; if param2 was exactly 48 we cannot send next byte (to many)
	breq	SkipFillingZeros
	rcall	lcdSendByte
	dec		counter


	
FillWithZeroesLoop:
	cp		counter,zero
	breq	SkipFillingZeros
	clr param
	rcall LcdSendByte
	dec		counter
	rjmp FillWithZeroesLoop
SkipFillingZeros:


	dec param2
	rjmp WriteLoopDR

DisplayRacketEnd:
	ret
;---------------------------------------------------------------------------
; clear ball
; Parameters:
;	param  - destroyed
;	tmp	   - destroyed
;---------------------------------------------------------------------------
ClearBall:

	ldi     param,0x21 ; command
    rcall   LcdCommand
    lds param, rBallXPos 
    rcall   LcdCommand
	lds param, rBallXPos 
	inc		param; the ball has 2 columns and so next column is end of column
    rcall   LcdCommand

	 ; set page start/end adress
	; pages are vertical adresses
    ldi     param,0x22 ; command
    rcall   LcdCommand
    ldi     param,0xB0 ; only last 3 bist matter
    rcall   LcdCommand
    ldi     param,0xB7
    rcall   LcdCommand

	ldi tmp, 16
ClearBallLoop:
	dec tmp
	clr param
	rcall LcdSendByte
	cpse tmp,zero
	rjmp ClearBallLoop


	ret



;---------------------------------------------------------------------------
; Display Ball	(also rembers the new ball position)
; Parameters:
;	param  - destroyed
;	tmp	   - destroyed
;   param1 - Y (bits) position (0 means touching high)
;   param2 - X (bits) position (generally 2 or 124)
;	param1 - has to be from 0 to 48; destroyed in process
;	param2 - has to be from 0 to 126; 
;---------------------------------------------------------------------------
DisplayBall:

	sts rBallYPos,param1
	sts rBallXPos,param2

	; Set column start/end address
	; column adress is x position in bits
    ldi     param,0x21 ; command
    rcall   LcdCommand
    mov     param, param2 ; argument 1,  column begin
    rcall   LcdCommand
	mov     param, param2
	inc		param; the racket has 2 columns and so next column is end of column
    rcall   LcdCommand

    ; set page start/end adress
	; pages are vertical adresses
    ldi     param,0x22 ; command
    rcall   LcdCommand
    ldi     param,0xB0 ; only last 3 bist matter
    rcall   LcdCommand
    ldi     param,0xB7
    rcall   LcdCommand

	ldi		 param2,2
WriteLoopDB:
	cp		param2,zero
	breq	DisplayBallEnd


	; target to write is set
	ldi		tmp,8
	mov		counter, tmp 
	mov		tmp, param1
	lsr		tmp
	lsr		tmp
	lsr		tmp ; now we have number of bytes to write 0s
	sub		counter, tmp ; remember how many bytes skipped
	mov		param,zero
	cp		tmp,zero 
	breq	AfterLoopDB
	
ZerosLoopDB:
	clr param
	rcall	LcdSendByte;
	dec		tmp;
	cpse	tmp, zero
	rjmp	ZerosLoopDB
AfterLoopDB:
	
	mov		param, ff 
	mov		tmp, param1
	andi	tmp, 0x07; 00000111 geting last 3 bits, 

	cpi tmp, 7; the only way we have to use 2 bytes
	breq BallOnBytes
	ldi param, 0x03 ; 00000011

ShiftLoop1DB:
	cp tmp,zero
	breq AfterShiftLoop1DB
	dec tmp
	lsl param
	rjmp ShiftLoop1DB

AfterShiftLoop1DB:
	rcall LcdSendByte
	dec counter
	rjmp FillWithZeroesLoopDB
BallOnBytes:
	ldi param,0x80 ; 1000 0000
	rcall LcdSendByte
	dec counter
	ldi param,0x01 ; 0000 0001
	rcall LcdSendByte
	dec counter
	
FillWithZeroesLoopDB:
	cp		counter,zero
	breq	SkipFillingZerosDB
	clr param
	rcall LcdSendByte
	dec		counter
	rjmp FillWithZeroesLoopDB
SkipFillingZerosDB:



	dec param2
	rjmp WriteLoopDB

DisplayBallEnd:
	ret


;---------------------------------------------------------------------------
; CtrlRackets - control and move rackets
; Parameters:
;	param  - destroyed
;	tmp	   - destroyed
;   param1 - destroyed
;   param2 - destroyed
;---------------------------------------------------------------------------
CtrlRackets:
	sbrs     flags,F_TICK
	rjmp CtrlRacketsEnd
	cbr     flags,(1<<F_TICK)
	;; tick is here

	sbrs	 flags, F_P1_UP
	rjmp	SkipP1Up
	lds param1, rP1RacketPos
	cp param1,zero
	breq SkipP1Up
	dec param1
	sts rP1RacketPos,param1
	ldi param2, RACKET_FROM_END
	rcall DisplayRacket
SkipP1Up:

	sbrs	 flags, F_P1_DOWN
	rjmp	SkipP1DOWN
	lds param1, rP1RacketPos
	cpi param1, DISPLAY_Y_SIZE-RACKET_SIZE
	breq SkipP1DOWN
	inc param1
	sts rP1RacketPos,param1
	;ldi param2, 
	ldi param2, RACKET_FROM_END
	rcall DisplayRacket
SkipP1DOWN:


	sbrs	 flags, F_P2_UP
	rjmp	SkipP2Up
	lds param1, rP2RacketPos
	cp param1,zero
	breq SkipP2Up
	dec param1
	sts rP2RacketPos,param1
	ldi param2, DISPLAY_X_SIZE-RACKET_FROM_END - RACKET_X_SIZE
	rcall DisplayRacket
SkipP2Up:


	sbrs	 flags, F_P2_DOWN
	rjmp	SkipP2DOWN
	lds param1, rP2RacketPos
	cpi param1, DISPLAY_Y_SIZE-RACKET_SIZE
	breq SkipP2DOWN
	inc param1
	sts rP2RacketPos,param1
	ldi param2, DISPLAY_X_SIZE-RACKET_FROM_END - RACKET_X_SIZE
	rcall DisplayRacket
SkipP2DOWN:
CtrlRacketsEnd:
	ret


;---------------------------------------------------------------------------
; CtrlBall - control and move Ball 
; Parameters:
;	param  - destroyed
;	tmp	   - destroyed
;	counter -destroyed
;   param1 - destroyed
;   param2 - destroyed
;---------------------------------------------------------------------------
CtrlBall:


; moving ball up and down:
	sbrs	flagsBall,F_TICK_Y
	rjmp	CtrlBallX
	cbr		flagsBall,(1<<F_TICK_Y)
	lds		param1,rBallYPos
	lds		param2,rBallXPos


	sbrs    flagsBall,F_BALL_UP
	rjmp	BallDown
	; ball Y speed is up
	cpse	param1, zero
	rjmp	BallUpSpeedNoChange

	;; we just hit the top
	inc		param1 
	rcall	ClearBall ; does not change param1 or param2
	rcall	DisplayBall
	cbr		flagsBall, (1<<F_BALL_UP) ; set that speed is down
	rjmp	CtrlBallX

BallUpSpeedNoChange:
	dec		param1 ; move one up
	rcall	ClearBall ; does not change param1 or param2
	rcall	DisplayBall

	rjmp	CtrlBallX
BallDown:
	ldi		param, DISPLAY_Y_SIZE - BALL_SIZE
	cpse	param1,param
	rjmp	BallDownSpeedNoChange
	; hit bottom
	sbr		flagsBall, (1<<F_BALL_UP) ; set that speed is up
	dec		param1 ; move one up
	rcall	ClearBall ; does not change param1 or param2
	rcall	DisplayBall

	rjmp	CtrlBallX
BallDownSpeedNoChange:
	inc		param1 ; move down
	rcall	ClearBall ; does not change param1 or param2
	rcall	DisplayBall

CtrlBallX:
	sbrs     flagsBall,F_TICK_X
	rjmp	CtrlBallEnd

	cbr		flagsBall,(1<<F_TICK_X)

	lds		param1,rBallYPos
	lds		param2,rBallXPos


	sbrs    flagsBall,F_BALL_LEFT
	rjmp	BallRight
	;ball goes left
	ldi		param, (RACKET_FROM_END + RACKET_X_SIZE)
	cp	param2,param
	breq	BallLeftCanHit

	dec		param2
	rcall	ClearBall
	rcall	DisplayBall

	rjmp	CtrlBallEnd

BallLeftCanHit:

	lds		tmp, rP1RacketPos
	cp		tmp,zero ; racket being on zero is problematic
	breq	LeftRacketTop
	dec		tmp
	sub		param1,tmp ; if param1 < tmp, ball is above the racket
	brmi	BallMiss ; branch if result is negative, ergo param1 < tmp
	;inc tmp done in +1 below
	ldi		param1, (RACKET_SIZE) ; tmp points at the last (looking from top) pixel of racket
	add		tmp, param1
	lds		param1, rBallYPos ; restore param1
	inc		tmp ;; donno if works
	sub		param1,tmp ; if param1>tmp  ball misses
	brpl	BallMiss ; branch if positive
	; bounce

	rjmp	LeftBallBounce




LeftRacketTop:
	ldi		tmp, RACKET_SIZE -1 ; tmp set on last pixel of racket
	sub		param1,tmp ; if param1 >tmp   ball misses <is below>
	brpl	BallMiss ; branch if positive

	;rjmp	LeftBallBounce

	
LeftBallBounce:

	lds		param1,rBallYPos
	lds		param2,rBallXPos

	inc		param2
	rcall	ClearBall
	rcall	DisplayBall

	cbr		flagsBall,(1<<F_BALL_LEFT) ; clear if goes left flag

	rcall BallXSpeedInc
	;ldi		param, BALL_X_SPEED_STEP
	;sub		ballspeedX, param; increase X speed

	;adding Y speed
	ldi param, BALL_Y_SPEED_STEP
	sbrs	flags, F_P1_UP
	rjmp	P1NotUP
	sbrc    flagsBall,F_BALL_UP ; Both Ball And Racket going up => increase speed <decrease the number>, skip otherwise <if flag is 0>
	sub		ballspeedY,param
	sbrs	flagsBall,F_BALL_UP ; if both are going up, skip
	add		ballspeedY,param ; decrease speed

	rjmp CtrlBallEnd

P1NotUP:
	sbrc    flagsBall,F_BALL_UP ; 
	add		ballspeedY,param
	sbrs	flagsBall,F_BALL_UP ; if both are going up, skip
	sub		ballspeedY,param ; decrease speed

	rjmp CtrlBallEnd
	
;;---------------- is here due to branch range
BallMiss:
	cbr flags, (1<<F_GAME) ; set game to STOP
	;rjmp CtrlBallEnd
	rjmp CtrlBallEnd
;;---------------- is here due to branch range



BallRight:
	
	;ball goes right
	ldi		param, (DISPLAY_X_SIZE - RACKET_X_SIZE - RACKET_FROM_END - BALL_SIZE)
	cp	param2,param
	breq	BallRightCanHit
	; ball cannot hit yet
	inc		param2
	rcall	ClearBall
	rcall	DisplayBall

	rjmp	CtrlBallEnd

BallRightCanHit:

	lds		tmp, rP2RacketPos
	cp		tmp,zero ; racket being on zero is problematic
	breq	RightRacketTop
	dec		tmp
	sub		param1,tmp ; if param1 < tmp, ball is above the racket
	brmi	BallMiss ; branch if result is negative, ergo param1 < tmp
	;inc tmp done in +1 below
	ldi		param1, (RACKET_SIZE) ; tmp points at the last (looking from top) pixel of racket
	add		tmp, param1
	lds		param1, rBallYPos ; restore param1
	inc		tmp ;; donno if works
	sub		param1,tmp ; if param1>tmp  ball misses
	brpl	BallMiss ; branch if positive
	; bounce

	rjmp	RightBallBounce




RightRacketTop:
	ldi		tmp, RACKET_SIZE -1 ; tmp set on last pixel of racket
	sub		param1,tmp ; if param1 >tmp   ball misses <is below>
	brpl	BallMiss ; branch if positive

	;rjmp	RightBallBounce ;;not necessary

	
RightBallBounce:

	lds		param1,rBallYPos
	lds		param2,rBallXPos

	dec		param2
	rcall	ClearBall
	rcall	DisplayBall

	sbr		flagsBall,(1<<F_BALL_LEFT) ; set if goes left flag

	rcall BallXSpeedInc
	;ldi		param, BALL_X_SPEED_STEP
	;sub		ballspeedX, param; increase X speed

	;adding Y speed
	ldi param, BALL_Y_SPEED_STEP
	sbrs	flags, F_P2_UP
	rjmp	P2NotUP
	sbrc    flagsBall,F_BALL_UP ; Both Ball And Racket going up => increase speed <decrease the number>, skip otherwise <if flag is 0>
	sub		ballspeedY,param
	sbrs	flagsBall,F_BALL_UP ; if both are going up, skip
	add		ballspeedY,param ; decrease speed
	rjmp CtrlBallEnd
P2NotUP:
	sbrc    flagsBall,F_BALL_UP ; 
	add		ballspeedY,param
	sbrs	flagsBall,F_BALL_UP ; if both are going up, skip
	sub		ballspeedY,param ; decrease speed







	rjmp CtrlBallEnd


CtrlBallEnd:
	ret



;------------------------------------------------------------------------------
; BallXSpeedInc = increase the speed of the ball up to 8
; param,tmp - destroyed
;------------------------------------------------------------------------------
BallXSpeedInc:
	mov param, ballspeedX
	lsr param
	lsr param
	lsr param ;divide by 8
	cp param,zero
	breq BallXSpeedIncBelow8
	sub ballspeedX, param ; 
	rjmp BallXSpeedIncEnd

BallXSpeedIncBelow8:
	
	dec ballspeedX ; dec by exactly one

BallXSpeedIncEnd:
	ret




