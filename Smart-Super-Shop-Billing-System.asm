
.MODEL SMALL
.STACK 200H

; ----------------------------------------------------------------
;                        DATA SEGMENT
; ----------------------------------------------------------------

.DATA

BANNER          DB 'Welcome to SuperMart Shopping System',0DH,0AH,'$'

DEPT_MENU       DB 0DH,0AH,'== Select Department ==',0DH,0AH
                DB '[1] Daily Essentials',0DH,0AH
                DB '[2] Cold Drinks',0DH,0AH
                DB '[3] Snack Corner',0DH,0AH
                DB 'Enter Number: $'

; ---- Daily Essentials ----
FOOD_LIST       DB 0DH,0AH,'--- Daily Essentials ---',0DH,0AH
                DB '[1] Sugar  (Price: 80 TK)',0DH,0AH
                DB '[2] Salt   (Price: 25 TK)',0DH,0AH
                DB 'Pick item: $'

; ---- Cold Drinks ----
BEV_LIST        DB 0DH,0AH,'--- Cold Drinks ---',0DH,0AH
                DB '[1] Mango Drink  (Price: 35 TK)',0DH,0AH
                DB '[2] Lemon Water  (Price: 20 TK)',0DH,0AH
                DB 'Pick item: $'

; ---- Snack Corner ----
SNACK_LIST      DB 0DH,0AH,'--- Snack Corner ---',0DH,0AH
                DB '[1] Crackers  (Price: 45 TK)',0DH,0AH
                DB '[2] Popcorn   (Price: 30 TK)',0DH,0AH
                DB 'Pick item: $'

QTY_MSG         DB 0DH,0AH,'Enter Quantity: $'

; ---- Receipt Labels ----
DIVIDER         DB '================================',0DH,0AH,'$'
LBL_ITEM        DB 'Product  : $'
LBL_UNITS       DB 0DH,0AH,'Quantity : $'
LBL_SUBTOT      DB 0DH,0AH,'Subtotal : $'
LBL_REBATE      DB 0DH,0AH,'Discount : $'
LBL_PAYABLE     DB 0DH,0AH,'Net Bill : $'
SUFFIX_TK       DB ' TK',0DH,0AH,'$'

; ---- Lucky Draw Display Labels ----
LBL_PREVIOUS    DB 0DH,0AH,'Previous Bill      : $'
LBL_LUCKY_DISC  DB 'Lucky Draw Discount: $'
LBL_UPDATED     DB 'Updated Bill       : $'

; ---- Product Names ----
P_SUGAR         DB 'Sugar$'
P_SALT          DB 'Salt$'
P_MANGO         DB 'Mango Drink$'
P_LEMON         DB 'Lemon Water$'
P_CRACKER       DB 'Crackers$'
P_POPCORN       DB 'Popcorn$'

; ---- Lucky Draw Messages ----
GAME_ASK        DB 0DH,0AH,'Want to try Lucky Draw? (Y/N): $'
BOX_PROMPT      DB 0DH,0AH,'Select Box [1], [2] or [3]: $'
RES_WIN5        DB 0DH,0AH,'Box 1: Congrats! 5% extra off!',0DH,0AH,'$'
RES_WIN10       DB 0DH,0AH,'Box 2: Congrats! 10% extra off!',0DH,0AH,'$'
RES_LOSE        DB 0DH,0AH,'Box 3: No luck! Try next time.',0DH,0AH,'$'

; ---- Prices ----
RATE_SUGAR      DW 80
RATE_SALT       DW 25
RATE_MANGO      DW 35
RATE_LEMON      DW 20
RATE_CRACKER    DW 45
RATE_POPCORN    DW 30

; ---- Variables ----
UNIT_PRICE      DW ?
NUM_UNITS       DW ?
SUBTOTAL        DW ?
REBATE_AMT      DW ?
NET_PAYABLE     DW ?
ITEM_PTR        DW ?
LUCKY_DISC_AMT  DW ?

; ----------------------------------------------------------------
;                        CODE SEGMENT
; ----------------------------------------------------------------

.CODE
BEGIN PROC

    MOV AX, @DATA
    MOV DS, AX

    ; Print Banner
    MOV AH, 09H
    LEA DX, BANNER
    INT 21H

; ---- Department Selection ----
    MOV AH, 09H
    LEA DX, DEPT_MENU
    INT 21H

    MOV AH, 01H
    INT 21H
    SUB AL, 30H

    CMP AL, 1
    JE  DEPT_FOOD
    CMP AL, 2
    JE  DEPT_BEV
    CMP AL, 3
    JE  DEPT_SNACK
    JMP QUIT

; ----------------------------------------------------------------
;  Daily Essentials
; ----------------------------------------------------------------
DEPT_FOOD:
    MOV AH, 09H
    LEA DX, FOOD_LIST
    INT 21H

    MOV AH, 01H
    INT 21H
    SUB AL, 30H

    CMP AL, 1
    JE  SEL_SUGAR
    CMP AL, 2
    JE  SEL_SALT
    JMP QUIT

SEL_SUGAR:
    MOV UNIT_PRICE, 80
    LEA DX, P_SUGAR
    MOV ITEM_PTR, DX
    JMP READ_QTY

SEL_SALT:
    MOV UNIT_PRICE, 25
    LEA DX, P_SALT
    MOV ITEM_PTR, DX
    JMP READ_QTY

; ----------------------------------------------------------------
;  Cold Drinks
; ----------------------------------------------------------------
DEPT_BEV:
    MOV AH, 09H
    LEA DX, BEV_LIST
    INT 21H

    MOV AH, 01H
    INT 21H
    SUB AL, 30H

    CMP AL, 1
    JE  SEL_MANGO
    CMP AL, 2
    JE  SEL_LEMON
    JMP QUIT

SEL_MANGO:
    MOV UNIT_PRICE, 35
    LEA DX, P_MANGO
    MOV ITEM_PTR, DX
    JMP READ_QTY

SEL_LEMON:
    MOV UNIT_PRICE, 20
    LEA DX, P_LEMON
    MOV ITEM_PTR, DX
    JMP READ_QTY

; ----------------------------------------------------------------
;  Snack Corner
; ----------------------------------------------------------------
DEPT_SNACK:
    MOV AH, 09H
    LEA DX, SNACK_LIST
    INT 21H

    MOV AH, 01H
    INT 21H
    SUB AL, 30H

    CMP AL, 1
    JE  SEL_CRACKER
    CMP AL, 2
    JE  SEL_POPCORN
    JMP QUIT

SEL_CRACKER:
    MOV UNIT_PRICE, 45
    LEA DX, P_CRACKER
    MOV ITEM_PTR, DX
    JMP READ_QTY

SEL_POPCORN:
    MOV UNIT_PRICE, 30
    LEA DX, P_POPCORN
    MOV ITEM_PTR, DX
    JMP READ_QTY

; ----------------------------------------------------------------
;  Read Quantity & Calculate
; ----------------------------------------------------------------
READ_QTY:
    MOV AH, 09H
    LEA DX, QTY_MSG
    INT 21H

    MOV AH, 01H
    INT 21H
    SUB AL, 30H
    MOV AH, 0
    MOV NUM_UNITS, AX

    ; Subtotal = Quantity x Unit Price
    MOV AX, NUM_UNITS
    MOV BX, UNIT_PRICE
    MUL BX
    MOV SUBTOTAL, AX

; ----------------------------------------------------------------
;  Discount Rules
;  Above 1000 TK -> 20% off
;  Above 500 TK  -> 10% off
;  500 or below  -> no discount
; ----------------------------------------------------------------
    MOV AX, SUBTOTAL

    CMP AX, 1000
    JG  DISC_20
    CMP AX, 500
    JG  DISC_10

    ; No Discount
    MOV REBATE_AMT, 0
    MOV NET_PAYABLE, AX
    JMP SHOW_BILL

DISC_10:
    MOV AX, SUBTOTAL
    MOV BX, 10
    MUL BX
    MOV BX, 100
    DIV BX
    MOV REBATE_AMT, AX
    MOV BX, AX
    MOV AX, SUBTOTAL
    SUB AX, BX
    MOV NET_PAYABLE, AX
    JMP SHOW_BILL

DISC_20:
    MOV AX, SUBTOTAL
    MOV BX, 20
    MUL BX
    MOV BX, 100
    DIV BX
    MOV REBATE_AMT, AX
    MOV BX, AX
    MOV AX, SUBTOTAL
    SUB AX, BX
    MOV NET_PAYABLE, AX

; ----------------------------------------------------------------
;  Print Receipt
; ----------------------------------------------------------------
SHOW_BILL:
    MOV AH, 09H
    LEA DX, DIVIDER
    INT 21H

    ; Product Name
    MOV AH, 09H
    LEA DX, LBL_ITEM
    INT 21H
    MOV AH, 09H
    MOV DX, ITEM_PTR
    INT 21H

    ; Quantity
    MOV AH, 09H
    LEA DX, LBL_UNITS
    INT 21H
    MOV AX, NUM_UNITS
    CALL SHOW_NUM

    ; Subtotal
    MOV AH, 09H
    LEA DX, LBL_SUBTOT
    INT 21H
    MOV AX, SUBTOTAL
    CALL SHOW_NUM
    MOV AH, 09H
    LEA DX, SUFFIX_TK
    INT 21H

    ; Discount
    MOV AH, 09H
    LEA DX, LBL_REBATE
    INT 21H
    MOV AX, REBATE_AMT
    CALL SHOW_NUM
    MOV AH, 09H
    LEA DX, SUFFIX_TK
    INT 21H

    ; Net Bill
    MOV AH, 09H
    LEA DX, LBL_PAYABLE
    INT 21H
    MOV AX, NET_PAYABLE
    CALL SHOW_NUM
    MOV AH, 09H
    LEA DX, SUFFIX_TK
    INT 21H

    MOV AH, 09H
    LEA DX, DIVIDER
    INT 21H

; ----------------------------------------------------------------
;  Lucky Draw
; ----------------------------------------------------------------
    MOV AH, 09H
    LEA DX, GAME_ASK
    INT 21H

    MOV AH, 01H
    INT 21H

    CMP AL, 'Y'
    JE  PLAY_DRAW
    CMP AL, 'y'
    JE  PLAY_DRAW
    JMP QUIT

PLAY_DRAW:
    MOV AH, 09H
    LEA DX, BOX_PROMPT
    INT 21H

    MOV AH, 01H
    INT 21H
    SUB AL, 30H

    CMP AL, 1
    JE  BOX_ONE
    CMP AL, 2
    JE  BOX_TWO
    JMP BOX_THREE

; ---- Box 1 : 5% off ----
BOX_ONE:
    MOV AX, NET_PAYABLE
    PUSH AX                  

    MOV BX, 5
    MUL BX
    MOV BX, 100
    DIV BX
    MOV LUCKY_DISC_AMT, AX   

    POP AX                   
    MOV BX, LUCKY_DISC_AMT
    SUB AX, BX
    MOV NET_PAYABLE, AX      

    MOV AH, 09H
    LEA DX, RES_WIN5
    INT 21H
    JMP SHOW_LUCKY_UPDATE

; ---- Box 2 : 10% off ----
BOX_TWO:
    MOV AX, NET_PAYABLE
    PUSH AX                  

    MOV BX, 10
    MUL BX
    MOV BX, 100
    DIV BX
    MOV LUCKY_DISC_AMT, AX   

    POP AX                   
    MOV BX, LUCKY_DISC_AMT
    SUB AX, BX
    MOV NET_PAYABLE, AX      

    MOV AH, 09H
    LEA DX, RES_WIN10
    INT 21H
    JMP SHOW_LUCKY_UPDATE

; ---- Box 3 : No luck ----
BOX_THREE:
    MOV AH, 09H
    LEA DX, RES_LOSE
    INT 21H
    JMP QUIT

; ----------------------------------------------------------------
;  Show Lucky Draw Summary
; ----------------------------------------------------------------
SHOW_LUCKY_UPDATE:

    ; Previous Bill = NET_PAYABLE + LUCKY_DISC_AMT
    MOV AH, 09H
    LEA DX, LBL_PREVIOUS
    INT 21H
    MOV AX, NET_PAYABLE
    ADD AX, LUCKY_DISC_AMT
    CALL SHOW_NUM
    MOV AH, 09H
    LEA DX, SUFFIX_TK
    INT 21H

    ; Lucky Draw Discount
    MOV AH, 09H
    LEA DX, LBL_LUCKY_DISC
    INT 21H
    MOV AX, LUCKY_DISC_AMT
    CALL SHOW_NUM
    MOV AH, 09H
    LEA DX, SUFFIX_TK
    INT 21H

    ; Updated Bill
    MOV AH, 09H
    LEA DX, LBL_UPDATED
    INT 21H
    MOV AX, NET_PAYABLE
    CALL SHOW_NUM
    MOV AH, 09H
    LEA DX, SUFFIX_TK
    INT 21H

    JMP QUIT

; ----------------------------------------------------------------
;  Exit
; ----------------------------------------------------------------
QUIT:
    MOV AH, 4CH
    INT 21H

BEGIN ENDP

; ================================================================
;  SHOW_NUM : Prints number in AX to screen
; ================================================================
SHOW_NUM PROC

    MOV CX, 0
    MOV BX, 10

NEXT_DIGIT:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE NEXT_DIGIT

PRINT_DIGIT:
    POP DX
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
    LOOP PRINT_DIGIT

    RET

SHOW_NUM ENDP

END BEGIN



