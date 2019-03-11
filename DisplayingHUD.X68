*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START: 
    MOVE.B  #100,PLAYER_HEALTH
    
    LEA     MSG_ENTER_NAME,A1
    MOVE.B  #13,D0
    TRAP    #15
   
    LEA     PLAYER_NAME,A1
    MOVE.B  #2,D0
    TRAP    #15
    
    MOVE.B  #14,D0
    
    LEA     MSG_GREETING0,A1
    TRAP    #15
    
    LEA     PLAYER_NAME,A1
    TRAP    #15
    
    LEA     MSG_GREETING1,A1
    TRAP    #15
    
    BSR     PRESS_ENTER
    
    BSR     CLEAR_SCREEN
    
    BSR     DISPLAY_HUD
    
    BSR     EXIT
       
DISPLAY_HUD:

    BSR     SCREEN_DECORATION
    
    MOVE.B  #14,D0
    
    LEA     HUD_NAME,A1
    TRAP    #15
    
    LEA     PLAYER_NAME,A1
    TRAP    #15
    
    LEA     HUD_HEALTH,A1
    TRAP    #15
    
    MOVE.B  #10,D2
    MOVE.B  (PLAYER_HEALTH),D1
    MOVE.B  #15,D0
    TRAP    #15
    
    MOVE.B  #14,D0
    LEA     CRLF,A1
    TRAP    #15
    
    BSR     SCREEN_DECORATION
    
    RTS
    
SCREEN_DECORATION:

    LEA     SCREENLINE,A1
    MOVE.B  #13,D0
    TRAP    #15
    RTS
    
PRESS_ENTER:

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
    rts
    
EXIT:

    SIMHALT 
    
CRLF:           DC.B    $0D,$0A,0

SCREENLINE:     DC.B    '~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~',0

HUD_NAME:       DC.B    $09,'NAME: ',0
HUD_HEALTH:     DC.B    $09,$09,$09,$09,$09,$09,'HEALTH: ',0

MSG_ENTER:      DC.B    $0D,$0A,'Press Enter to Continue',0  

MSG_ENTER_NAME: DC.B    'What is your name?',0

MSG_GREETING0:  DC.B    'Hi, ',0
MSG_GREETING1:  DC.B    '; welcome to Avalon!',0

PLAYER_NAME:    EQU     $6000
PLAYER_HEALTH:  EQU     $6100

    END    START
 
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
