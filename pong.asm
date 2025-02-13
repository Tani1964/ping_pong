.MODEL SMALL
.STACK 100

.DATA
    TIME_AUX DB 0

    BALL_X DW 50    ; Initial X-coordinate (somewhere visible)
    BALL_Y DW 50    ; Initial Y-coordinate
    BALL_SIZE DW 10 ; Ball size (width and height)
    BALL_VELOCITY_X DW 05H
    BALL_VELOCITY_Y DW 02H

    SCREEN_WIDTH DW 320
    SCREEN_HEIGHT DW 200

.CODE
MAIN:
    ; Initialize Data Segment
    MOV AX, @DATA
    MOV DS, AX

    ; Set Video Mode 13h (320x200 256 colors)
    
    CALL CLEAR_SCREEN

CHECK_TIME:
    ; GET SYSTEM TIME
    MOV AH, 2CH
    INT 21H

    ; COMPARE CURRENT TIME TO LAST SAVED TIME
    CMP DL, TIME_AUX
    JE CHECK_TIME  ; If time has not changed, wait

    MOV TIME_AUX, DL

    CALL CLEAR_SCREEN

    CALL MOVE_BALL

    CALL DRAW_BALL

    JMP CHECK_TIME  ; Keep updating (infinite loop)

DRAW_BALL PROC NEAR
    ; Outer loop for Y-coordinate
    MOV DX, BALL_Y
DRAW_VERTICAL:
    ; Inner loop for X-coordinate
    MOV CX, BALL_X
DRAW_HORIZONTAL:
    ; Plot pixel at (CX, DX)
    MOV AH, 0CH        ; Function: Write pixel
    MOV AL, 0DH        ; Color: Light Purple
    MOV BH, 00H        ; Video page
    INT 10H

    INC CX             ; Move to next X position
    MOV AX, CX
    SUB AX, BALL_X
    CMP AX, BALL_SIZE
    JL DRAW_HORIZONTAL ; Continue horizontal drawing

    INC DX             ; Move to next Y position
    MOV AX, DX
    SUB AX, BALL_Y
    CMP AX, BALL_SIZE
    JL DRAW_VERTICAL   ; Continue vertical drawing

    RET
DRAW_BALL ENDP

MOVE_BALL PROC NEAR
    MOV AX, BALL_VELOCITY_X
    ADD BALL_X, AX

    MOV AX, BALL_VELOCITY_Y
    ADD BALL_Y, AX 
MOVE_BALL ENDP


CLEAR_SCREEN PROC NEAR
    MOV AH, 00H
    MOV AL, 13H
    INT 10H
    RET
CLEAR_SCREEN ENDP

END MAIN