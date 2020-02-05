
;
; Constants
;
      .set ADCH, 0x79            ; A/D result, high byte
      .set ADCL, 0x78            ; A/D result, low byte
      .set ADCSRA, 0x7A          ; A/D control reg A
      .set ADCSRA_INITVAL, 0x87  ; control value
      .set ADMUX, 0x7C           ; A/D mux control reg
      .set ADMUX_INITVAL, 0x60   ; set mux to select internal +5V
      .set DIDR0, 0x7E           ; Data setup control reg 0
      .set DIDR0_INITVAL, 0x3F   ; setup control value
      .set ADSC, 6               ; A/D input pin select

      .data
      .comm charX,1
      .global charX
      .comm charY,1
      .global charY
      .comm bposX,3
      .global bposX
      .comm bposY,3
      .global bposY
      .comm endGame,1
      .global endGame
      .comm level, 1
      .global level

;
; Program code
;            
      .text
      .global readAD
      .global initAD
      .global control
      .global initGame
      .global checkCollision


; function initAD: 1-time initialize of A/D system
initAD:
      ldi   r25, DIDR0_INITVAL
      sts   DIDR0, r25
      ldi   r25, ADMUX_INITVAL
      sts   ADMUX, r25
      ldi   r25, ADCSRA_INITVAL
      sts   ADCSRA, r25
      ret

;
; function readAD: set up an A/D reading, take the
; reading, and return a 16-bit result in r25:r24
;
readAD:
      lds   r25, ADMUX
      andi  r25, 0xF0
      or    r25, r24
      sts   ADMUX, r25
      lds   r25, ADCSRA
      ori   r25, 0x40
      sts   ADCSRA, r25

   
radwait:
      lds   r25, ADCSRA
      sbrc  r25, ADSC
      rjmp   radwait
      lds   r25, ADCL    
      lds   r24, ADCH
      ret

initGame:
      ldi r18,0
      sts charX, r18
      ldi r18,1
      sts charY, r18
      call moveCursor
      call printChar
      ret

      


controlX:

      ldi r24, 0
      call readAD
      cpi r24, 255
      breq moveRRight
      cpi r24, 200
      brsh moveRight
      cpi r24, 0
      breq moveLLeft
      cpi r24,128
      brlo moveLeft
      ret

moveLeft:
      lds r23, charX
      dec r23
      cpi r23, 0
      brlt exit1
      sts charX, r23
      ret

moveLLeft:
      lds r23, charX
      dec r23
      dec r23
      cpi r23, 0
      brlt exit1
      sts charX, r23
      ret
      
moveRight:
      lds r23, charX
      inc r23
      cpi r23,16
      brge win
      sts charX, r23
      ret
moveRRight:
      lds r23, charX
      inc r23
      inc r23
      cpi r23,16
      brge win
      sts charX, r23
      ret

controlY:
      ldi r24, 1
      call readAD
      cpi r24, 245
      brsh moveUp
      cpi r24,15
      brlo moveDown
      ret

moveUp:
      lds r23, charY
      inc r23
      cpi r23, 2
      brge exit1
      sts charY, r23
      ret

moveDown:
      lds r23, charY
      dec r23
      cpi r23, 0
      brlt exit1
      sts charY, r23
      ret

exit1:
      ret

control:
      call moveCursor
      call printNull
      call controlX
      call controlY
      call moveCursor
      call printChar
      ret


win:
      call printWin
      ldi r18, 1
      sts endGame, r18
      ret

checkCollision:
      ldi r26, lo8(bposX)
      ldi r27, hi8(bposX)
      ldi r28, lo8(bposY)
      ldi r29, hi8(bposY)
      lds r22, charX
      lds r23, charY
      ldi r25, 3

iter:
      ld r24, x+
      ld r21, y+
      cp r22, r24
      brne good
      cp r23, r21
      brne bad

good:
      dec r25
      cpi r25, 0
      brne iter
      ret

bad: 
      call printLose
      ldi r18, 1
      sts endGame, r18
      ldi r18, 4
      sts level, r18
      ret

