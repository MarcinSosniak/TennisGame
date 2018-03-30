
Delay_5ms:
    push    param
    push    param1

    ldi     param1,  (( CPU_CLOCK / 80400 ) +2 )
Delay_5ms_loop1:
    ldi     param, 0x80
Delay_5ms_loop2:
    dec     param
    brne    Delay_5ms_loop2

    dec     param1
    brne    Delay_5ms_loop1

    pop     param1
    pop     param
	

	ret 
;; GENERAL LCD INIT


InitLcd:


; CPHA = 0 - sample at 1st clock
; CPOL = 0 - mode 0
; DORD = 0 - MSB 1st
; MSTR = 1 - master
; SPR1:SPR2 = 11 - fosc/128
; initalize SPI port

    cbi     PORT_LCD_RST,IN_LCD_RST     ; Reset display controller
    rcall   Delay_5ms
    sbi     PORT_LCD_RST,IN_LCD_RST
    rcall   Delay_5ms


    in      param,SPSR
    in      param,SPDR  ; clear SPIF bit

    ldi     param,(1<<SPE)|(1<<MSTR)//|(1<<SPR1)|(1<<SPR0)
    out     SPCR,param


.IFDEF _SIMULATING_
    ret
.ENDIF

; 100ms delay loop
    ldi     param,20
InitLcdInitDelayLoop:
    rcall   Delay_5ms
    dec     param
    brne    InitLcdInitDelayLoop

    ; selected_spi.send(0xA8,0); selected_spi.send(0x3F,0); //set MUX ratio (pierwsze to komenda drugie to dane)
    ldi     param,0xA8
    rcall   LcdCommand
    ldi     param,0x3F
    rcall   LcdCommand

    ;selected_spi.send(0xD3,0); selected_spi.send(0x00,0); //Set display Offset 0
    ldi     param,0xD3
    rcall   LcdCommand
    ldi     param,0x00
    rcall   LcdCommand

    ;selected_spi.send(0x40,0); //set start line to 0
    ldi     param,0x40
    rcall   LcdCommand

    ;selected_spi.send(0xA0,0); // segment remap, zero=zero
    ldi     param,0xA0
    rcall   LcdCommand

    ;selected_spi.send(0xC0,0); //Set com output scan direction COM0->COM16
    ldi     param,0xC0
    rcall   LcdCommand

    ;selected_spi.send(0xDA,0); selected_spi.send(0x12,0); // COM pin hardwarde configuration
    ldi     param,0xDA
    rcall   LcdCommand
    ldi     param,0x12
    rcall   LcdCommand

    ;selected_spi.send(0x81,0); selected_spi.send(0x8F,0); // Set contrast
    ldi     param,0x81
    rcall   LcdCommand
    ldi     param,0x8F
    rcall   LcdCommand

    ;selected_spi.send(0xA4,0); //display on, clear ram
    ldi     param,0xA4
    rcall   LcdCommand

    ;selected_spi.send(0xA6,0); //1 in RAM means pixel turned ON
    ldi     param,0xA6
    rcall   LcdCommand

    ;selected_spi.send(0xD5,0); selected_spi.send(0x80,0); // set clock (i have no idea what i'm doing)
    ldi     param,0xD5
    rcall   LcdCommand
    ldi     param,0x80
    rcall   LcdCommand


    ;selected_spi.send(0x8D,0); selected_spi.send(0x14,0); // enable bump charge
    ldi     param,0x8D
    rcall   LcdCommand
    ldi     param,0x14
    rcall   LcdCommand

    ;selected_spi.send(0xAF,0); //display on
    ldi     param,0xAF
    rcall   LcdCommand

    //prepare to show data---------------------------------
    ;selected_spi.send(0x20,0); selected_spi.send(0x01,0); // Vertical adressing mode
    ldi     param,0x20
    rcall   LcdCommand
    ldi     param,0x01
    rcall   LcdCommand


    ;selected_spi.send(0x21,0);selected_spi.send(0x00,0);selected_spi.send(127,0); // Set column strart/end adress
    ldi     param,0x21
    rcall   LcdCommand
    ldi     param,0x00
    rcall   LcdCommand
    ldi     param,127
    rcall   LcdCommand


    ;selected_spi.send(0x22,0);selected_spi.send(0xB0,0);selected_spi.send(0xB7,0); // set page start/end adress B nie ma znaczenia bo przyjmuje tlyko trzy ostatnie bity
    ldi     param,0x22
    rcall   LcdCommand
    ldi     param,0xB0
    rcall   LcdCommand
    ldi     param,0xB7
    rcall   LcdCommand

    rcall   LcdSsd1306Clear

    ; set contrast
    ldi     param,0x81
    rcall   LcdCommand
    ldi     param,0xFF
    rcall   LcdCommand


	ret


;---------------------------------------------------------------------------
; Clscr
; Parameters:
;   none
;---------------------------------------------------------------------------
LcdSsd1306Clear:
    push    param
    push    param1
    push    param2

    ; Set column start/end address
    ldi     param,0x21
    rcall   LcdCommand
    ldi     param,0x00
    rcall   LcdCommand
    ldi     param,127
    rcall   LcdCommand

    ; set page start/end adress
    ldi     param,0x22
    rcall   LcdCommand
    ldi     param,0xB0
    rcall   LcdCommand
    ldi     param,0xB7
    rcall   LcdCommand

    ; clear LCD
    ldi     param1,0
    ldi     param2,4
LcdSsd1306ClearLoop:

    ldi     param, 0
    rcall   LcdSendByte

    dec     param1
    brne    LcdSsd1306ClearLoop

    dec     param2
    brne    LcdSsd1306ClearLoop

    pop     param2
    pop     param1
    pop     param

    ret


;---------------------------------------------------------------------------
; Write Byte into LCD data (non command)
; Parameters:
;   param - Byte to send
;---------------------------------------------------------------------------

LcdSendByte:

    out     SPDR,param
	
	LcdSendByteLoop:
    in      param,SPSR
    sbrs    param,SPIF
    rjmp    LcdSendByteLoop ;; wait for end of sending

    in      param,SPSR  ; for clearing SPIF bit only

    ret



;---------------------------------------------------------------------------
; Write Command 
; Parameters:
;   param - command
;---------------------------------------------------------------------------
LcdCommand:


    cbi     PORT_LCD_DC,IN_LCD_DC     ; Set to Command

    rcall   LcdSendByte

    sbi     PORT_LCD_DC,IN_LCD_DC     ; Set to Data

    ret



