.MODEL SMALL
.STACK 100

.DATA
    
	WINDOW_WIDTH DW 142h                 ;the width of the window (320 pixels)
	WINDOW_HEIGHT DW 0C8h                ;the height of the window (200 pixels)
	WINDOW_BOUNDS DW 1                  ;variable used to check collisions early
	
	TIME_AUX DB 0                        ;variable used when checking if the time has changed
	GAME_ACTIVE DB 1                     ;is the game active? (1 -> Yes, 0 -> No (game over))
	EXITING_GAME DB 0
	WINNER_INDEX DB 0                    ;the index of the winner (1 -> player one, 2 -> player two)
	CURRENT_SCENE DB 0                   ;the index of the current scene (0 -> main menu, 1 -> game)
	
	TEXT_PLAYER_ONE_POINTS DB '0','$'    ;text with the player one points
	TEXT_PLAYER_TWO_POINTS DB '0','$'    ;text with the player two points
	TEXT_GAME_OVER_TITLE DB 'GAME OVER','$' ;text with the game over menu title
	TEXT_GAME_OVER_WINNER DB 'Player 0 won','$' ;text with the winner text
	TEXT_GAME_OVER_PLAY_AGAIN DB 'Press R to play again','$' ;text with the game over play again message
	TEXT_GAME_OVER_MAIN_MENU DB 'Press E to exit to main menu','$' ;text with the game over main menu message
	TEXT_MAIN_MENU_TITLE DB 'MAIN MENU','$' ;text with the main menu title
	TEXT_MAIN_MENU_SINGLEPLAYER DB 'SINGLEPLAYER - S KEY','$' ;text with the singleplayer message
	TEXT_MAIN_MENU_MULTIPLAYER DB 'MULTIPLAYER - M KEY','$' ;text with the multiplayer message
	TEXT_MAIN_MENU_EXIT DB 'EXIT GAME - E KEY','$' ;text with the exit game message
	
	BALL_ORIGINAL_X DW 0A0h              ;X position of the ball on the beginning of a game
	BALL_ORIGINAL_Y DW 64h               ;Y position of the ball on the beginning of a game
	BALL_X DW 0A0h                       ;current X position (column) of the ball
	BALL_Y DW 64h                        ;current Y position (line) of the ball
	BALL_SIZE DW 06h                     ;size of the ball (how many pixels does the ball have in width and height)
	BALL_VELOCITY_X DW 05h               ;X (horizontal) velocity of the ball
	BALL_VELOCITY_Y DW 02h               ;Y (vertical) velocity of the ball
	
	PADDLE_LEFT_X DW 0Ah                 ;current X position of the left paddle
	PADDLE_LEFT_Y DW 55h                 ;current Y position of the left paddle
	PLAYER_ONE_POINTS DB 0              ;current points of the left player (player one)
	
	PADDLE_RIGHT_X DW 130h               ;current X position of the right paddle
	PADDLE_RIGHT_Y DW 55h                ;current Y position of the right paddle
	PLAYER_TWO_POINTS DB 0             ;current points of the right player (player two)
	
	PADDLE_WIDTH DW 06h                  ;default paddle width
	PADDLE_HEIGHT DW 25h                 ;default paddle height
	PADDLE_VELOCITY DW 0Fh               ;default paddle velocity
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

    CALL DRAW_PADDLES

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

DRAW_PADDLES PROC NEAR
		
		MOV CX,PADDLE_LEFT_X 			 ;set the initial column (X)
		MOV DX,PADDLE_LEFT_Y 			 ;set the initial line (Y)
		
		DRAW_PADDLE_LEFT_HORIZONTAL:
			MOV AH,0Ch 					 ;set the configuration to writing a pixel
			MOV AL,0Fh 					 ;choose white as color
			MOV BH,00h 					 ;set the page number 
			INT 10h    					 ;execute the configuration
			
			INC CX     				 	 ;CX = CX + 1
			MOV AX,CX         			 ;CX - PADDLE_LEFT_X > PADDLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,PADDLE_LEFT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			MOV CX,PADDLE_LEFT_X 		 ;the CX register goes back to the initial column
			INC DX       				 ;we advance one line
			
			MOV AX,DX            	     ;DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,PADDLE_LEFT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			
		MOV CX,PADDLE_RIGHT_X 			 ;set the initial column (X)
		MOV DX,PADDLE_RIGHT_Y 			 ;set the initial line (Y)
		
		DRAW_PADDLE_RIGHT_HORIZONTAL:
			MOV AH,0Ch 					 ;set the configuration to writing a pixel
			MOV AL,0Fh 					 ;choose white as color
			MOV BH,00h 					 ;set the page number 
			INT 10h    					 ;execute the configuration
			
			INC CX     					 ;CX = CX + 1
			MOV AX,CX         			 ;CX - PADDLE_RIGHT_X > PADDLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,PADDLE_RIGHT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
			MOV CX,PADDLE_RIGHT_X		 ;the CX register goes back to the initial column
			INC DX       				 ;we advance one line
			
			MOV AX,DX            	     ;DX - PADDLE_RIGHT_Y > PADDLE_HEIGHT (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,PADDLE_RIGHT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
		RET
	DRAW_PADDLES ENDP

MOVE_BALL PROC NEAR
    ; Move X position
    MOV AX, BALL_VELOCITY_X
    ADD BALL_X, AX

    ; Check if ball hits the left boundary
    MOV AX, WINDOW_BOUNDS
    SUB AX, BALL_SIZE
    CMP BALL_X, AX
    JL RESET_POSITION

    ; Check if ball hits the right boundary
    MOV AX, WINDOW_WIDTH
    SUB AX, WINDOW_BOUNDS
    SUB AX, BALL_SIZE
    CMP BALL_X, AX
    JG RESET_POSITION

    ; Move Y position
    MOV AX, BALL_VELOCITY_Y
    ADD BALL_Y, AX

    ; Check if ball hits the top boundary
    MOV AX, WINDOW_BOUNDS 
    CMP BALL_Y, AX
    JL NEG_VELOCITY_Y

    ; Check if ball hits the bottom boundary
    MOV AX, WINDOW_HEIGHT
    SUB AX, WINDOW_BOUNDS
    SUB AX, BALL_SIZE
    CMP BALL_Y, AX
    JG NEG_VELOCITY_Y

    RET

RESET_POSITION:
    CALL RESET_BALL_POSITION
    RET


NEG_VELOCITY_X:
    NEG BALL_VELOCITY_X
    RET

NEG_VELOCITY_Y:
    NEG BALL_VELOCITY_Y
    RET

MOVE_BALL ENDP

RESET_BALL_POSITION PROC NEAR        ;restart ball position to the original position
		
		MOV AX,BALL_ORIGINAL_X
		MOV BALL_X,AX
		
		MOV AX,BALL_ORIGINAL_Y
		MOV BALL_Y,AX
		
		NEG BALL_VELOCITY_X
		NEG BALL_VELOCITY_Y
		
		RET
	RESET_BALL_POSITION ENDP


CLEAR_SCREEN PROC NEAR
    MOV AH, 00H
    MOV AL, 13H
    INT 10H
    RET
CLEAR_SCREEN ENDP

END MAIN