*-----------------------------------------------------------
* Title      : Avalon Project
* Written by : Ben Millar
*-----------------------------------------------------------
* Note: Memory location $6000 is the game state indicator
* 1 = Dialogue, 2 = Combat, 0 = NULL
*
* in dialogue, data register 7 is used as a dialogue step counter
*

    ORG    $1000
START:

    BSR     PRINT_TITLE
    BSR     INTRO
    BSR     EXIT

PRINT_TITLE:

    LEA     MSG_TITLE,A1
    MOVE.B  #13,D0  
    TRAP    #15
    
    BSR     PRESS_ENTER
    
    BSR     CLEAR_SCREEN
    
    RTS
    
INTRO:

    BSR     START_DIALOGUE          Change gamestate to dialogue

    BSR     SCREEN_DECORATION
    
    CMP     #0,D7
    BGE     INTRO_TEXT1

    CMP     #1,D7
    BGE     INTRO_TEXT2
    
    BSR     SCREEN_DECORATION
    
    BSR     PRESS_ENTER
        
    RTS
    
INTRO_TEXT1:

    LEA     MSG_INTRO1,A1
    MOVE.B  #13,D0
    TRAP    #15
    
    LEA     CRLF,A1
    TRAP    #15
    
    RTS
    
INTRO_TEXT2:

    LEA     MSG_INTRO2,A1
    MOVE.B  #13,D0
    TRAP    #15
    
    LEA     CRLF,A1
    TRAP    #15
    
    RTS
    
START_DIALOGUE:

    MOVE.B  DIALOGUE,$6000
    MOVE.W  #0000,D7
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
    
DIALOGUE:       EQU     1
    
CRLF:           DC.B    $0D,$0A,0

SCREENLINE:     DC.B    '~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~',$0D,$0A,0

MSG_TITLE:      DC.B    '        _______________________________________________________________' 
                DC.B    $0D,$0A
                DC.B    '       / ________  __   ___  ________  ___      ________  ___   ___   /\'
                DC.B    $0D,$0A
                DC.B    '      / /  _    / /  / /  / /  _    / /  /     /  __   / /   | /  /  /\/'
                DC.B    $0D,$0A
                DC.B    '     / /  /_/  / /  / /  / /  /_/  / /  /     /  / /  / /    |/  /  /\/'
                DC.B    $0D,$0A
                DC.B    '    / /  _    / /  / /  / /  _    / /  /     /  / /  / /  /|    /  /\/'
                DC.B    $0D,$0A
                DC.B    '   / /  / /  /  \  \/  / /  / /  / /  /____ /  /_/  / /  / |   /  /\/'
                DC.B    $0D,$0A
                DC.B    '  / /__/ /__/    \____/ /__/ /__/ /_______//_______/ /__/  |__/  /\/'
                DC.B    $0D,$0A
                DC.B    ' /______________________________________________________________/\/'
                DC.B    $0D,$0A
                DC.B    ' \__\\\__\\\__\\\__\\\__\\\__\\\__\\\__\\\__\\\__\\\__\\\__\\\__\/'
                DC.B    $0D,$0A,$0D,$0A,$0D,$0A,$0D,$0A,$0D,$0A,$0D,$0A,$0D,$0A,0
MSG_ENTER:      DC.B    $0D,$0A,'Press Enter to Continue',0  

MSG_INTRO1:     DC.B    'Your head is pounding. '
                DC.B    $0D,$0A,'You become aware of muffled voices around you, talking, but you can',$27,'t'
                DC.B    $0D,$0A,'quite make out what they’re saying.',0
MSG_INTRO2:     DC.B    'As the seconds pass, you begin to regain your senses.'
                DC.B    $0D,$0A,'You can feel that you',$27,'re lying on the ground. It',$27,'s cold, and less than comfortable.'
                DC.B    $0D,$0A,'Slowly, you open your eyes and begin to look around.',0


          
    END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
