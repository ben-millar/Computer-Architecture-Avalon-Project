; GAME STATES: 
;   0 = Introduction
;   1 = Travelling
;   2 = Outside town
;   3 = Inside town
;   4 = Item shop
;   5 = Weapon shop
;   6 = Art shop


    ORG    $1000
START: 
    MOVE.B  #100,PLAYER_HEALTH *init player health to 100
    MOVE.B  #100,PLAYER_COINS *init player coins to 50
    MOVE.B  #0,PLAYER_POTIONS *init player potions to 0
    MOVE.B  #2,GAME_STATE *Set game state to OUTSIDE TOWN
    MOVE.B  #0,DIALOGUE_STEP *init dialogue step to 0
    MOVE.B  #0,PLAYER_HAS_SWORD *init player sword to false
    
    BSR     PRINT_TITLE
 
    BSR     INPUT_NAME
    
    BSR     GAME_LOOP
    
    BSR     EXIT
    
    
PRINT_TITLE:

    LEA     MSG_TITLE,A1
    MOVE.B  #13,D0  
    TRAP    #15
    
    BSR     PRESS_ENTER
    
    BSR     CLEAR_SCREEN
    
    RTS
    
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
       
    BSR     RENDER
    
    BSR     TAKE_INPUT

    BSR     GAME_LOOP
    
    
TAKE_INPUT:

    * Check GAME STATE and forward as appropriate
    MOVE.B  (GAME_STATE),D4
    CMP     #0,D4
    BEQ     INTRODUCTION
    
    CMP     #1,D4
    BEQ     MOVEMENT
    
    CMP     #2,D4
    BEQ     OUTSIDE_TOWN
    
    CMP     #3,D4
    BEQ     INSIDE_TOWN
    
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
    
INTRODUCTION:
    
    RTS
    
OUTSIDE_TOWN:

    LEA     ART_OUTSIDE_TOWN,A1     *Load and display ASCII art
    MOVE.B  #13, D0
    TRAP    #15
    
    LEA     MSG_OUTSIDE_TOWN,A1     *Display description of area
    TRAP    #15
    
    MOVE.B  #4,D0                   *Take user input       
    TRAP    #15
    
    *Branch based on input
    CMP     #1,D1
    BEQ     INSIDE_TOWN
    
    CMP     #2,D1
    BEQ     MOVEMENT
    
    RTS

INSIDE_TOWN:

    MOVE.B  #3,GAME_STATE       *Set game state to IN TOWN
    
    LEA     ART_INSIDE_TOWN,A1  *Load and display ASCII art
    MOVE.B  #13, D0
    TRAP    #15
    
    LEA     MSG_INSIDE_TOWN,A1  *Display description of area
    MOVE.B  #13, D0
    TRAP    #15
    
    MOVE.B  #4,D0               *Take user input
    TRAP    #15
    
    *Branch based on input
    CMP     #1, D1
    BEQ     ITEM_SHOP
    
    CMP     #2, D1
    BEQ     WEAPON_SHOP

    CMP     #3, D1
    BEQ     ART_SHOP

    CMP     #4, D1
    BEQ     OUTSIDE_TOWN

  
    RTS
    
ITEM_SHOP:

    BSR     RENDER

    MOVE.B  #4,GAME_STATE       *Set game state to ITEM SHOP
    
    LEA     MSG_ITEM_SHOP,A1    *Display description of area
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #4,D0               *Take user input
    TRAP    #15
    
    *Branch based on input
    CMP.B   #0, D1              *If 0, return to town. Otherwise, continue to buy potions
    BEQ     INSIDE_TOWN
    
    MOVE.B  D1,D3               *Copy value of D1 to D3, so it can be used as an interation counter
    BGT     BUY_POTION
    
    BRA     GAME_LOOP
    
BUY_POTION:

    CMP.B   #15,PLAYER_COINS    *Compares decimal 15 to player coins
    BGE     POTION_SUCCESS      *if player coins >= 15, buy is successful
    BLT     POTION_FAIL         *else, go to fail
    
POTION_SUCCESS:

    SUB.B   #1,D3               *D3 stores number of potions player wants to buy, we will use this as an iteration count
    SUB.B   #15,PLAYER_COINS    *Remove 15 coins from player
    
    ADD.B   #1,PLAYER_POTIONS   *Give the player a potion!
    
    CMP.B   #0,D3               *if 0 < D3, recursively loop through buy potion
    BGT     BUY_POTION
    
    LEA     MSG_POTION_SUCCESS0,A1  *Load start of purchase success message
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #3,D0                   *Display number of potions bought
    TRAP    #15
    
    LEA     MSG_POTION_SUCCESS1,A1  *Load end of purchase success message
    MOVE.B  #14,D0
    TRAP    #15
    
    BSR     PRESS_ENTER             *Press enter to continue
    
    JSR     ITEM_SHOP               *Jump back to item shop

POTION_FAIL:

    LEA     MSG_POTION_FAIL0,A1 *Load start of purchase fail message
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #3,D0               *Display value of D1 (this will be number potions player attempted to buy)
    TRAP    #15
    
    LEA     MSG_POTION_FAIL1,A1 *Load end of purchase fail message
    MOVE.B  #14,D0
    TRAP    #15
    
    SUB.B   D3,D1               *Take away remainder from original number, leaving total num bought
    MOVE.B  #3,D0               *Display total bought
    TRAP    #15
    
    BSR     PRESS_ENTER         *Press enter to continue
    
    JSR     ITEM_SHOP           *Jump back to item shop


WEAPON_SHOP:

    BSR     RENDER

    MOVE.B  #5,GAME_STATE       *Set game state to WEAPON SHOP
    
    LEA     MSG_WEAPON_SHOP,A1  *Display description of area
    MOVE.B  #13,D0
    TRAP    #15
    
    MOVE.B  #4,D0               *Take user input
    TRAP    #15
    
    *Branch based on input
    CMP     #0, D1
    BEQ     INSIDE_TOWN
    
    CMP     #1, D1
    BEQ     BUY_SWORD
    
    BRA     WEAPON_SHOP
    
BUY_SWORD:

    CMP.B   #1,PLAYER_HAS_SWORD     *checks if player has already bought the sword
    BEQ     ALREADY_OWN_SWORD
    
    CMP.B   #30,(PLAYER_COINS)      *check if player has enough coins
    BGT     SWORD_SUCCESS
    BLE     SWORD_FAIL 

    JSR     WEAPON_SHOP  

ALREADY_OWN_SWORD:

    LEA     MSG_SWORD_FAIL,A1  *Tells player they already own a sword
    MOVE.B  #13,D0
    TRAP    #15
    
    BSR     PRESS_ENTER
    
    JSR     WEAPON_SHOP
   
SWORD_SUCCESS:

    SUB.B   #30,PLAYER_COINS            *Take 30 coins away from player
    ADD.B   #1,PLAYER_HAS_SWORD         *Mark that player has sword

    LEA     MSG_PURCHASE_SUCCESS,A1     *Show success message
    MOVE.B  #13,D0          
    TRAP    #15
    
    BSR     PRESS_ENTER                 *Press enter to continue
    
    JSR     WEAPON_SHOP                 *Jump back to weapon shop
    
SWORD_FAIL:   

    LEA     MSG_PURCHASE_FAIL,A1        *Show fail message
    MOVE.B  #13,D0      
    TRAP    #15
    
    BSR     PRESS_ENTER                 *press enter to continue
    
    JSR     WEAPON_SHOP                 *Jump back to weapon shop
    
ART_SHOP:
     
    MOVE.B  #6,GAME_STATE       *Set game state to ART SHOP
    RTS
    
MOVEMENT:              

    MOVE.B  #1,GAME_STATE       *Set game state to TRAVELLING
    
    LEA     msg_instructions,A1     *Tells player to type 1-4 to move NSEW
    MOVE.B  #13,D0
    TRAP    #15
    
    MOVE.B  #4,D0                   *Take in number from keyboard
    TRAP    #15
    
    CMP     #1,D1                   *Check number and branch to relevant SR
    BEQ     north
    CMP     #2,D1
    BEQ     south
    CMP     #3,D1
    BEQ     east
    CMP     #4,D1
    BEQ     west
    
    BSR     invalid
    
    RTS

NORTH:
    
    LEA     MSG_NORTH,A1
    MOVE.B  #13,D0
    TRAP    #15
    
    BSR     PRESS_ENTER
    
    RTS
    
SOUTH:
    
    LEA     MSG_SOUTH,A1
    MOVE.B  #13,D0 
    TRAP    #15
    
    BSR     PRESS_ENTER
    
    RTS
    
EAST:
    
    LEA     MSG_EAST,A1
    MOVE.B  #13,D0
    TRAP    #15
    
    BSR     PRESS_ENTER
    
    RTS
    
WEST:
    
    LEA     MSG_WEST,A1
    MOVE.B  #13,D0
    TRAP    #15
    
    BSR     PRESS_ENTER
    
    RTS
    
INVALID:
    LEA     MSG_INVALID,A1
    MOVE.B  #13,D0
    TRAP    #15
    BSR     MOVEMENT
    
    
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

MSG_GREETING0:      DC.B    'Hi, ',0
MSG_GREETING1:      DC.B    '; welcome to Avalon!',0
                    
MSG_TITLE:          DC.B    '    ______________________________________________________________________',$0D,$0A
                    DC.B    '   ========================================================================',$0D,$0A
                    DC.B    '  |                                                                        |',$0D,$0A
                    DC.B    '  |      :::     :::     :::     :::     :::        ::::::::  ::::    :::  |',$0D,$0A
                    DC.B    '  |    :+: :+:   :+:     :+:   :+: :+:   :+:       :+:    :+: :+:+:   :+:  |',$0D,$0A
                    DC.B    '  |   +:+   +:+  +:+     +:+  +:+   +:+  +:+       +:+    +:+ :+:+:+  +:+  |',$0D,$0A
                    DC.B    '  |  +#++:++#++: +#+     +:+ +#++:++#++: +#+       +#+    +:+ +#+ +:+ +#+  |',$0D,$0A
                    DC.B    '  |  +#+     +#+  +#+   +#+  +#+     +#+ +#+       +#+    +#+ +#+  +#+#+#  |',$0D,$0A 
                    DC.B    '  |  #+#     #+#   #+#+#+#   #+#     #+# #+#       #+#    #+# #+#   #+#+#  |',$0D,$0A 
                    DC.B    '  |  ###     ###     ###     ###     ### ########## ########  ###    ####  |',$0D,$0A
                    DC.B    '  |                                                                        |',$0D,$0A
                    DC.B    '   ========================================================================',$0D,$0A
                    DC.B    '    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""',$0D,$0A,$0D,$0A,$0D,$0A,$0D,$0A,0
                    
MSG_OUTSIDE_TOWN:   DC.B    $0D,$0A,$0D,$0A,'You find yourself outside a town; would you like to enter, or explore outside?'
                    DC.B    $0D,$0A,$0D,$0A 
                    DC.B    'Press 1 to ENTER TOWN'
                    DC.B    $0D,$0A,$0D,$0A
                    DC.B    'Press 2 to EXPLORE',0
                    
MSG_INSIDE_TOWN:    DC.B    $0D,$0A,$0D,$0A,'You look around and see that you are in a small medieval town, bustling'
                    DC.B    $0D,$0A
                    DC.B    'with people. You see in front of you an ITEM shop and a WEAPON shop,'
                    DC.B    $0D,$0A
                    DC.B    'and to the right, a sign for an ARTIST.'
                    DC.B    $0D,$0A,$0D,$0A
                    DC.B    'Press 1 to enter ITEM SHOP'   
                    DC.B    $0D,$0A,$0D,$0A
                    DC.B    'Press 2 to enter WEAPON SHOP'
                    DC.B    $0D,$0A,$0D,$0A
                    DC.B    'Press 3 to go to ARTISTs house'
                    DC.B    $0D,$0A,$0D,$0A
                    DC.B    'Press 4 to EXIT the city',0  
                    
MSG_ITEM_SHOP:      DC.B    $0D,$0A,'You enter the item shop, and the owner greets you cheerfully:',$0D,$0A,$0D,$0A
                    DC.B    '   "Hello my friend! Can I interest you in some potions?',$0D,$0A
                    DC.B    '    Or perhaps, some ... other potions? ... I will be honest,',$0D,$0A
                    DC.B    '    I do not have anything but potions here. But I can assure',$0D,$0A
                    DC.B    '    you, they are of the highest quality! Mostly!"',$0D,$0A,$0D,$0A
                    DC.B    'A sign on the wall reads "Potions: 15 coins". How many potions would you like?',$0D,$0A,$0D,$0A
                    DC.B    'Enter number [0 to exit shop]: ',0
                    
MSG_WEAPON_SHOP:    DC.B    $0D,$0A,'You enter the weapon shop; the owner seems displeased.',$0D,$0A,$0D,$0A,$0D,$0A
                    DC.B    '   "Sword. 25 coins.", the owner grunts.',$0D,$0A,$0D,$0A
                    DC.B    '   "Oh. Do you have anything els--", you begin',$0D,$0A,$0D,$0A
                    DC.B    '   "30 coins", he interrupts. You decide not to ask any more questions.',$0D,$0A,$0D,$0A,$0D,$0A
                    DC.B    'Would you like to buy a sword for 30 coins?',$0D,$0A,$0D,$0A
                    DC.B    '[1] Yes, support local business!',$0D,$0A
                    DC.B    '[0] No thanks, I',$27,'d rather go pull one out of a stone.',$0D,$0A,0
MSG_ARTIST:

MSG_POTION_SUCCESS0:     DC.B   $0D,$0A,$0D,$0A,'You have successfully bought ',0
MSG_POTION_SUCCESS1:     DC.B   ' potion/s!',0

MSG_POTION_FAIL0:        DC.B   $0D,$0A,$0D,$0A,'Sorry, you can',$27,'t afford ',0
MSG_POTION_FAIL1:        DC.B   ' potion/s. Instead, you bought: ',0

MSG_PURCHASE_SUCCESS:   DC.B    $0D,$0A,'Purchase successful!',$0D,$0A,0
MSG_PURCHASE_FAIL:      DC.B    $0D,$0A,$0D,$0A,'I',$27,'m sorry, it doesn',$27,'t look like you have enough',$0D,$0A 
                        DC.B    'coins for this purchase',$0D,$0A,0

MSG_SWORD_FAIL:         DC.B    $0D,$0A,'You already have one of those!',$0D,$0A
                        DC.B    'Assembly 68k doesn',$27,'t support duel wielding',0

ART_OUTSIDE_TOWN    DC.B    '                                    |>>>',$0D,$0A 
                    DC.B    '                                    |',$0D,$0A 
                    DC.B    '                      |>>>      _  _|_  _         |>>>',$0D,$0A 
                    DC.B    '                      |        |;| |;| |;|        |',$0D,$0A 
                    DC.B    '                  _  _|_  _    \\.    .  /    _  _|_  _',$0D,$0A 
                    DC.B    '                 |;|_|;|_|;|    \\:. ,  /    |;|_|;|_|;|',$0D,$0A 
                    DC.B    '                 \\..      /    ||;   . |    \\.    .  /',$0D,$0A 
                    DC.B    '                  \\.  ,  /     ||:  .  |     \\:  .  /',$0D,$0A 
                    DC.B    '                   ||:   |_   _ ||_ . _ | _   _||:   |',$0D,$0A 
                    DC.B    '                   ||:  .|||_|;|_|;|_|;|_|;|_|;||:.  |',$0D,$0A 
                    DC.B    '                   ||:   ||.    .     .      . ||:  .|',$0D,$0A 
                    DC.B    '                   ||: . || .     . .   .  ,   ||:   |       \,/',$0D,$0A 
                    DC.B    '                   ||:   ||:  ,  _______   .   ||: , |            /`\',$0D,$0A 
                    DC.B    '                   ||:   || .   /+++++++\    . ||:   |',$0D,$0A 
                    DC.B    '                   ||:   ||.    |+++++++| .    ||: . |',$0D,$0A 
                    DC.B    '                __ ||: . ||: ,  |+++++++|.  . _||_   |',$0D,$0A 
                    DC.B    '       ____--`~    ;--~~__|.    |+++++__|----~    ~`---,           ___',$0D,$0A 
                    DC.B    '-~--~                  ~---__|,--~                   ~~----_____-~;   `~----~~',$0D,$0A,0  
                    
ART_INSIDE_TOWN     DC.B    '             )                     (',$0D,$0A
                    DC.B    '       [1]  (                 [2]   )                [3]',$0D,$0A
                    DC.B    '    ________[]_           _________[]_',$0D,$0A
                    DC.B    '   /^=^-^-^=^-^\         /^~^~^~^~^~^~\         .^_________',$0D,$0A
                    DC.B    '  /^-^-^-^-^-^-^\       /^ ^ ^  ^ ^ ^ ^\        ||Artist ->/',$0D,$0A
                    DC.B    ' /__^_^_^_^^_^_^_\     /_^_^_^^_^_^_^_^_\       ||""""""""',$0D,$0A   
                    DC.B    '  |  .==. ITEMs |       | WEAPONs.--.  |        ||',$0D,$0A
                    DC.B    '^^|  |LI|  [}{] |^^^^^^^| |[}{]| |[]|  |^^^^^^^^||^^^^',$0D,$0A
                    DC.B    '8&|__|__|_______|&8   8&|_+====+_|__|__|8&8&8&8\||/.:::::.',$0D,$0A
                    DC.B    '     =::=                        =::=             .::::::.',$0D,$0A
                    DC.B    '=====::::========================::::====.:::::::::::::::::::.',$0D,$0A
                    DC.B    ':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.',$0D,$0A
                    DC.B    '=+-+=+-+=+-+=+-+=+-+=+-+=+-+=+-+=+-+=+|.::::::./+=+-+=+',$0D,$0A
                    DC.B    '&&8&&8&&8&&8&&8&&8&&8&&8&&8&&8&&8&& +|.::::::./+',$0D,$0A 
                    DC.B    '   	,,      ,,,     ,      , 8& +|.::::::./+',$0D,$0A 
                    DC.B    '  ,,,,    ,,,         ,,,   ,, 8& +|.::::::./+',$0D,$0A
                    DC.B    '=+-+=+-+=+-+=+-+=+-+=+-+=+-+=+-+=+|.::::::./+',$0D,$0A
                    DC.B    '_|___|___|___|___|___|___|___|___|.::::::./+',$0D,$0A 
                    DC.B    '::::::::::::::::::::::::::::::::::::::::::.',$0D,$0A
                    DC.B    ':::::::::::::::::::::::::::::::::::::::::::.',0
                
ART_PHIL:           DC.B        '                                    `-:+ooyyo+:-..```   '                                            
                    DC.B        '                            `:/shhyyyhhhhyyysso+o+/:::-.`,',$0D,$0A                                
                    DC.B        '                         `.:/+shyyyyydddhddhhhhysooossso::`',$0D,$0A                                    
                    DC.B        '                       ./+ossyhyyhhdmmdddmmmmmdmdhdhhhyyss/.',$0D,$0A                                   
                    DC.B        '                   -+syhhhddddddddmmNmddddmNmmNNmdhdddhys+.  ',$0D,$0A                                
                    DC.B        '                   `:oydhdmNNNNmmmNmmmmmmdddddh+::/oshdmmmdys/',$0D,$0A                                  
                    DC.B        '                 ./yhhhdmmNmmNNNNmmmmmmmmddhys-      .+hdmdhs+`',$0D,$0A                                 
                    DC.B        '                -+hddhddmmmmmNNNNNNNNmmdhhyo:.         `:sysss+`',$0D,$0A                                
                    DC.B        '             `/syhddddmmmmNNNNNNNNmmmmds+-`             `://ss+.',$0D,$0A                             
                    DC.B        '           `syhdmmmmmmmNNNNNNNmdhyso/-`                  `.-/so` ',$0D,$0A                            
                    DC.B        '            /dmNNNNNNmmNNNNNdho:.`                          `-+ys`',$0D,$0A                            
                    DC.B        '            odNNNNNmmmNNNms/-`                               .+yh+ ',$0D,$0A                           
                    DC.B        '           omNNNNNdo+oo+.                                    -oss  ',$0D,$0A                         
                    DC.B        '            odmmmmh.                                           /ss-',$0D,$0A                          
                    DC.B        '           +yhhdd-                                             /y+ ',$0D,$0A                         
                    DC.B        '           +hdyoo                                              -so`',$0D,$0A                         
                    DC.B        '          +mNhs:                                   ````.-:-:::/++- ',$0D,$0A                        
                    DC.B        '          /NMmy`                               `-+o+++//:-:mmNhss/ ',$0D,$0A                        
                    DC.B        '          .mNmo                             -+o+:`         /M+  `` ',$0D,$0A                         
                    DC.B        '            ymmo                 ```.-:-`..:h+.              h-    ',$0D,$0A                          
                    DC.B        '            -dmy         `./+o+++++//-/mMNhyd/               y`    ',$0D,$0A                          
                    DC.B        '            sdh-    ./sho/.`          /N-   o-            .+/      ',$0D,$0A                         
                    DC.B        '            `hdyooymMNM/              -d     :+-     .-:::.        ',$0D,$0A                         
                    DC.B        '                .ohdyyhhdNo              +/       .:---`           ',$0D,$0A                           
                    DC.B        '                 ``    `:h-           .//                          ',$0D,$0A                           
                    DC.B        '                         `+/-..-::::--`                            ',$0D,$0A                           
                    DC.B        '                            `.--.`               .---------....``  ',$0D,$0A                            
                    DC.B        '                                        `:+syhdmNNNNNNNmmmddhys:`  ',$0D,$0A                          
                    DC.B        '                                    -/shmNMNNNNNNMNNNNMMMMMNNmh+`  ',$0D,$0A                          
                    DC.B        '                                .+hmNNNMMMNmdyyyssossydNMMMNy:`    ',$0D,$0A                         
                    DC.B        '                                `+dNMMMNdyo:.```        ``.-/:`    ',$0D,$0A                           
                    DC.B        '                            `+hNMMMN/.`                            ',$0D,$0A                         
                    DC.B        '                            `omNNNhs/         ``......`            ',$0D,$0A                          
                    DC.B        '                            `://.`       -osyhddmmmmmd/            ',$0D,$0A                         
                    DC.B        '                                        /hmNNNNMMMMMMNs.           ',$0D,$0A                         
                    DC.B        '                                        /mNNMMMMMMMMMmo.           ',$0D,$0A                         
                    DC.B        '                                        `+hmNMMMMMMMMm+`           ',$0D,$0A                         
                    DC.B        '                                          .odMMMMMMMNh:            ',$0D,$0A                         
                    DC.B        '                                           `/dNMMMMMm+`            ',$0D,$0A                         
                    DC.B        '                                             :yNMNMNy.             ',$0D,$0A                         
                    DC.B        '                                                -oyys+-            ',$0D,$0A                           
                    DC.B        '                                                  `` ',0

msg_instructions    dc.b    'Enter:'
                    dc.b    $0D,$0A
                    dc.b    '1 to go North'
                    dc.b    $0D,$0A
                    dc.b    '2 to go South'
                    dc.b    $0D,$0A
                    dc.b    '3 to go East'
                    dc.b    $0D,$0A
                    dc.b    '4 to go West',0
msg_north           dc.b    $0D,$0A
                    dc.b    'You travel NORTH',$0D,$0A,0
msg_south           dc.b    $0D,$0A
                    dc.b    'You travel SOUTH',$0D,$0A,0
msg_east            dc.b    $0D,$0A
                    dc.b    'You travel EAST',$0D,$0A,0
msg_west            dc.b    $0D,$0A
                    dc.b    'You travel WEST',$0D,$0A,0
msg_invalid         dc.b    $0D,$0A
                    dc.b    'I am sorry, that was an invalid entry',0
                    dc.b    $0D,$0A
                  

PLAYER_HEALTH:      EQU     $6000 *store player health
PLAYER_COINS:       EQU     $6001 *store player coins num
PLAYER_POTIONS      EQU     $6002 *store player potions
PLAYER_NAME:        EQU     $6003 *store player name

*64 bytes skipped for player name, to be safe
GAME_STATE:         EQU     $6043 *track gamestate
DIALOGUE_STEP:      EQU     $6044 *tracks progress through dialogue
PLAYER_HAS_SWORD:   EQU     $6045 *1 if player has sword, 0 otherwise


    END    START
 





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
