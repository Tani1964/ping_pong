.MODEL SMALL
.STACK 100

.DATA
    BALL_X DW 50   ; Initial X-coordinate (somewhere visible)
    BALL_Y DW 50   ; Initial Y-coordinate
    BALL_SIZE DW 10 ; Ball size (width and height)

.CODE
MAIN:
    ; Initialize Data and Stack Segments
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, @STACK
    MOV SS, AX

    ; Set Video Mode 13h (320x200 256 colors)
    MOV AH, 00H
    MOV AL, 13H
    INT 10H

    CALL DRAW_BALL

    ; Wait for keypress and exit
    MOV AH, 0
    INT 16H

    ; Restore text mode (03h)
    MOV AH, 00H
    MOV AL, 03H
    INT 10H

    RET

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

END MAIN
