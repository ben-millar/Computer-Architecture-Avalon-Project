*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START: 
    MOVE.B  #100,PLAYER_HEALTH
    MOVE.B  #50,PLAYER_COINS
 
    BSR     INPUT_NAME
    
    BSR     GAME_LOOP
    
    BSR     EXIT
    
    
INPUT_NAME:


    LEA     MSG_ENTER_NAME,A1       *Asks for player name
    MOVE.B  #13,D0
    TRAP    #15
   
    LEA     PLAYER_NAME,A1          *Load address of PLAYER_NAME equ into A1
    MOVE.B  #2,D0                   *Take text input from user, passes to player_name address via A1
    TRAP    #15
    
    MOVE.B  #14,D0
    
    *Displays greeting to player
    LEA     MSG_GREETING0,A1        
    TRAP    #15
    
    LEA     PLAYER_NAME,A1
    TRAP    #15
    
    LEA     MSG_GREETING1,A1
    TRAP    #15
    
    BSR     PRESS_ENTER
    
    BSR     CLEAR_SCREEN
    
    RTS
    
    
GAME_LOOP:
    
    BSR     TAKE_INPUT
    
    BSR     RENDER

    BSR     GAME_LOOP
    
    
TAKE_INPUT:
    
    BSR     PRESS_ENTER
    
    RTS

RENDER:

    BSR     CLEAR_SCREEN
    BSR     DISPLAY_HUD
    
    RTS
   
DISPLAY_HUD:

    BSR     SCREEN_DECORATION
    
    MOVE.B  #14,D0              *Print null terminated string
    
    LEA     HUD_NAME,A1         *Load 'NAME: ' text
    TRAP    #15
    
    LEA     PLAYER_NAME,A1      *Load player name EQU
    TRAP    #15
    
    LEA     HUD_HEALTH,A1       *Load 'HEALTH: ' text
    TRAP    #15
    
    MOVE.B  #3,D0               *Print decimal number
    
    MOVE.B  PLAYER_HEALTH,D1    *Dereference player health EQU to D1
    TRAP    #15
    
    MOVE.B  #14,D0              *Print null terminated string
    
    LEA     HUD_COINS,A1        *Load 'COINS: ' text
    TRAP    #15
    
    MOVE.B  #3,D0               *Print decimal number
    
    MOVE.B  PLAYER_COINS,D1     *Dereference player coins EQU to D1
    TRAP    #15
    
    MOVE.B  #14,D0              *Print null terminated string
    LEA     CRLF,A1
    TRAP    #15
    
    BSR     SCREEN_DECORATION
    
    RTS
    
SCREEN_DECORATION:  *Draws decorative line to screen

    LEA     SCREENLINE,A1
    MOVE.B  #13,D0
    TRAP    #15
    RTS
    
PRESS_ENTER:    *Displays the prompt 'Press enter to continue' on-screen

    LEA     MSG_ENTER,A1
    MOVE.B  #13,D0 
    TRAP    #15
    
    MOVE.B  #5,D0
    TRAP    #15
    
    RTS

CLEAR_SCREEN:
 
    move.b  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    
    move.w  #0000,D1    *clear value of D1
    rts
    
EXIT:

    SIMHALT 
    
CRLF:           DC.B    $0D,$0A,0

SCREENLINE:     DC.B    '~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~',0

HUD_NAME:       DC.B    $09,'NAME: ',0
HUD_HEALTH:     DC.B    $09,$09,$09,'HEALTH: ',0
HUD_COINS:      DC.B    $09,$09,$09,'COINS: ',0

MSG_ENTER:      DC.B    $0D,$0A,'Press Enter to Continue',0  

MSG_ENTER_NAME: DC.B    'What is your name?',0

MSG_GREETING0:  DC.B    'Hi, ',0
MSG_GREETING1:  DC.B    '; welcome to Avalon!',0

PLAYER_HEALTH:  EQU     $6000
PLAYER_COINS:   EQU     $6001
PLAYER_NAME:    EQU     $6005


    END    START
 

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
