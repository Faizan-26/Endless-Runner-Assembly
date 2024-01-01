[org 0x100]
jmp start

;-------------------------------------------------------------WELCOME SCREEN SPECIFIC ----------------------------------------------------
welcomeString: db 'Welcome  To  The Endless  Runner  Game', 0
pressKeyToStartString: db 'Press any key to Start game', 0
creditName1: db 'Faizan Tariq | Roll: 22F-3858', 0
loadingString: db 'LOADING', 0
;----------------------------------------------------------- SCORE AND LIFE SPECIFIC ----------------------------------------------------
ScoreString: db 'SCORES : ', 0
remainingLife: db 'Life count : ', 0
life:dw 3
scores: dw 0
;----------------------------------------------------------- CHARACTER AND ITS MOVEMENT SPECIFIC ------------------------------------------------------
charXcoordinate: dw 25 ; starting x coordinate of character
charYcoordinate: dw 20 ; starting y coordinate of character
CharacterBody : db '(0_0)', 0
CharacterBodyDeleted: db '     ', 0
;----------------------------------------------------------- OBSTACLE AND ITS MOVEMENT SPECIFIC ------------------------------------------------------
obstacleXcoordinate: dw 0
obstacleYcoordinate: dw 0
obstacleBody: db '$$$', 0
testLabel: db 'Obstacling', 0
scrollCheck: db ' ',0
AdditionSeed: dw 0
MIN_Y_COORDINATE dw 5
MAX_Y_COORDINATE dw 23
MIN_X_COORDINATE dw 2
MAX_X_COORDINATE dw 48
;-----------------------------------------------------------GAME PLAY INSTRUCTION SPECIFIC-----------------------------------------------
gameOverString : db 'GAME OVER', 0
yourScoreString : db 'You Scored :',0
gameMode : dw 2 ; on 2 gamemode is easy mode and on 1 game mode is hard mode
gameModeString: db 'Select Your Mode (EASY->ARROW UP , HARD->ARROW DOWN) :',0
;----------------------------------------------------------  SUBROUTINE SPECIFIC ------------------------------------
; call instructions here (say: subroutine)

; start of clrscr
; this subroutine takes no argument from start(main)
clrscr:
	push es 
	push ax 
	push cx 
	push di 
	mov ax, 0xb800 
	mov es, ax ; point es to video base 
	xor di, di ; point di to top left column 
	mov ax, 0x0720 ; space char in normal attribute 
	mov cx, 2000 ; number of screen locations 
	cld ; auto increment mode 
	rep stosw ; clear the whole screen 
	pop di
	pop cx 
	pop ax 
	pop es 
	ret 
;no changes in value of register used
; end of clrscr

;start of printString
;subroutine without specifying length 
;takes  x position, y position, attribute
printString:
	push bp 
	mov bp, sp 
	push es 
	push ax 
	push cx 
	push si 
	push di 
	push ds 
	pop es ; load ds in es 
	mov di, [bp+4] ; point di to string 
	mov cx, 0xffff ; load maximum number in cx 
	xor al, al ; load a zero in al 
	repne scasb ; find zero in the string 
	mov ax, 0xffff ; load maximum number in ax 
	sub ax, cx ; find change in cx 
	dec ax ; exclude null from length 
	jz exit ; no printing if string is empty
	mov cx, ax ; load string length in cx 
	mov ax, 0xb800 
	mov es, ax ; point es to video base 
	mov al, 80 ; load al with columns per row 
	mul byte [bp+8] ; multiply with y position 
	add ax, [bp+10] ; add x position 
	shl ax, 1 ; turn into byte offset 
	mov di,ax ; point di to required location 
	mov si, [bp+4] ; point si to string 
	mov ah, [bp+6] ; load attribute in ah 
	cld ; auto increment mode 
nextchar: 
	lodsb ; load next char in al 
	stosw ; print char/attribute pair 
	loop nextchar ; repeat for the whole string 
exit:
	pop di 
	pop si 
	pop cx 
	pop ax 
	pop es 
	pop bp 
	ret 8
; no changes in value of register used
; end of printString


;start of printNum on screen
; takes the number to be printed as its parameter 
printAnyNumber: 
	push bp 
	mov bp, sp 
	push es 
	push ax 
	push bx 
	push cx 
	push dx 
	push di 
	mov ax, 0xb800 
	mov es, ax ; point es to video base 
	; location determine for printing
	xor ax, ax
	mov al, 80 ; load al with columns per row 
	mul byte [bp+8] ; multiply with y position 
	add ax, [bp+10] ; add x position 
	shl ax, 1 ; turn into byte offset 
	mov di,ax ; point di to required location 
	
	;
	mov ax, [bp+4] ; load number in ax 
	mov bx, 10 ; use base 10 for division 
	mov cx, 0 ; initialize count of digits 
nextdigit:
	mov dx, 0 ; zero upper half of dividend 
	div bx ; divide by 10 
	add dl, 0x30 ; convert digit into ascii value 
	push dx ; save ascii value on stack 
	inc cx ; increment count of values 
	cmp ax, 0 ; is the quotient zero 
	jnz nextdigit ; if no divide it again 
	
nextpos: 
	pop dx ; remove a digit from the stack 
	mov dh, [bp+6] ; use given attribute 
	mov [es:di], dx ; print char on screen 
	add di, 2 ; move to next screen location 
	loop nextpos ; repeat for all digits on stack
	pop di 
	pop dx 
	pop cx 
	pop bx 
	pop ax 
	pop es 
	pop bp 
	ret 8
	
; start of drawborder
; this subroutine draw border on 4 side of screen
; takes no parameter
drawborder:
	push bp
	mov bp, sp
	push es
	push di
	push ax
	push cx
	push dx
	push bx
	; horizontal top line
	xor di, di
	mov ax, 0xb800
	mov es, ax
	mov cx, 80
	mov ax, 0x06db ;db is ascii for box
	repne stosw
	; vertical left and right lines
	mov cx, 23
	loopingforBorder1:
		mov [es:di], ax
		add di, 158
		mov [es:di], ax
		add di, 2
	loop loopingforBorder1
	; bottom line
	mov cx ,80
	repne stosw
	
	;end of draw border statments
	pop bx
	pop dx
	pop cx
	pop ax
	pop di
	pop es
	pop bp
	ret
; end of draw border no any register is changed

;start of welcome message
; takes no argument
PrintWelcomeScreen:
	push bp
	mov bp, sp
	push ax
	
	mov ax, 23 
	push ax ; push x position 
	mov ax, 8
	push ax ; push y position 
	mov ax, 0xE  
	push ax ; push attribute 
	mov ax,  welcomeString
	push ax ; push address of message 
	call printString ; welcome to endless runner game will print here
	
	
	mov ax, 26 
	push ax ; push x position 
	mov ax, 14
	push ax ; push y position 
	mov ax, 0x82  
	push ax ; push attribute 
	mov ax,  pressKeyToStartString
	push ax ; push address of message
	call printString ; Press any key to Start game
	; display credits
	; 1st credit name
	mov ax, 47 
	push ax ; push x position 
	mov ax, 21
	push ax ; push y position 
	mov ax, 0x0D  
	push ax ; push attribute 
	mov ax,  creditName1
	push ax ; push address of message
	call printString ; Press any key to Start game

	; inturrept to stop exectuion until user press any key
	
	mov ah , 0x1 ; input char is 0x1 in ah
	int 21h	
	pop ax
	pop bp
	ret

; end of welcome message
; every value of register is restored
;start of delay subroutine
delay: 	
	push cx
	mov cx, 0xFFFF
	delayLoop1:	
		dec cx
	jnz delayLoop1
	mov cx, 0xFFFF
	pop cx
	ret
;end of delay subrouting
;start if loading animation
loadingAnimation:
	push bp
	mov bp, sp
	push ax
	
	mov ax, 36 
	push ax ; push x position 
	mov ax, 12
	push ax ; push y position 
	mov ax, 0x02  
	push ax ; push attribute 
	mov ax,  loadingString
	push ax ; push address of message
	call printString ; Press any key to Start game
	
	loadpt: db '.',0
	call delay ; 10 times delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	mov ax, 43 
	push ax ; push x position 
	mov ax, 12
	push ax ; push y position 
	mov ax, 0x02  
	push ax ; push attribute 
	mov ax,  loadpt
	push ax ; push address of message
	call printString ; Press any key to Start game

	call delay ;4 times delay
	call delay
	call delay
	call delay

	mov ax, 44 
	push ax ; push x position 
	mov ax, 12
	push ax ; push y position 
	mov ax, 0x02  
	push ax ; push attribute 
	mov ax,  loadpt
	push ax ; push address of message
	call printString ; Press any key to Start game
	
	
	call delay ; 8 times delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	mov ax, 45 
	push ax ; push x position 
	mov ax, 12
	push ax ; push y position 
	mov ax, 0x02  
	push ax ; push attribute 
	mov ax,  loadpt
	push ax ; push address of message
	call printString ; Press any key to Start game
	
	call delay
	call delay
	call delay
	call delay
	
	pop ax
	pop bp
	ret
	; end of loadingAnimation
	; no change in any used register orignal value returned...
; intrupt instructions here

;Start of generating random number
; takes no parameter but return a random number that will be stored in dx register
; the random number is based on current system time
generateRandomNumber: 
	; generate numbers between 1-49
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	; make sure you dx has no currently usefull value
	
	mov ah, 00H; interupt for getting system time
	int 1ah
	mov ax, dx
	add ax, [AdditionSeed]
	mov [AdditionSeed], ax
	xor dx, dx
	mov cx, 49
	div cx ; dx contain remainder
	add dx, 1 ; range set from 1-49]

	pop cx
	pop bx
	pop ax
	pop bp
	ret
	; end of generateRandomNumber subrouting.. this subroute returns random number 1-49 in dx register

;start of displayObstacle
; takes no parameter, its coordinates x and y are stored in label above x and y is position where it will start displaying character
generateRandomObstacle:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push es
	push di
	xor dx, dx
	; get random number for x coordinate and y coordinte will always be 2
	call generateRandomNumber
	; now dx contain random value from 1-49
	mov word[obstacleXcoordinate], dx
	mov word[obstacleYcoordinate], 2
	
	; display random obstacle
	call displayObstacle
	
	pop di
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret
	
;start of displayCharacter
; takes no parameter, its coordinates x and y are stored in label above x and y is position where it will start displaying character
displayCharacter:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push es
	push di
	
	mov ax, [charXcoordinate] 
	push ax ; push x position 
	mov ax, [charYcoordinate]
	push ax ; push y position 
	mov ax, 0xE
	push ax ; push attribute 
	mov ax,  CharacterBody
	push ax ; push address of message 
	call printString ; welcome to endless runner game will print here
	
	
	pop di
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret


displayObstacle:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push es
	push di
	
	mov ax, [obstacleXcoordinate] 
	push ax ; push x position 
	mov ax, [obstacleYcoordinate]
	push ax ; push y position 
	mov ax, 0x04
	push ax ; push attribute 
	mov ax,  obstacleBody
	push ax ; push address of message 
	call printString ; welcome to endless runner game will print here
	
	
	pop di
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret

megaDelay:
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
ret
;start of scoreIncrement takes no parameter and return nothing just change value of SCORES
scoreIncrement:
	push ax
	mov ax, [scores]
	add ax, 1
	mov [scores], ax ; update SCORES
	pop ax
ret
;start of MoveObstaclesDown
; takes no paramter and return nothing
MoveObstaclesDown:
push bp
mov bp, sp
push es
	push di
	push ax
	push bx 
	push dx
	push cx
	mov di, 3838 ; address of 2nd last line
	mov ax, 0xb800
	mov es , ax
	mov al, '$'
	mov ah, 0x04
	mov cx, 4000
	
	loopingofMoveObstacleDown:
	std ; set flag because we want to move from dept to root (upward)
	push cx
		scasb
		jne skip
		push di ; save orignal di
		add di, 1; di was decremented because of scasb and std by 1 so i add by 1
		mov word[es:di], ' ' ; store ' ' on orignal
		add di , 160 ; jump di to next line
		mov [es:di], ax
		pop di
		skip:
	pop cx
	; again display endborder line because $$$ get overwrite also the registers should also not be affeced
	call AdjustBottomBorder
	loop loopingofMoveObstacleDown
	pop cx
	pop dx
	pop bx
	pop ax
	pop di
	pop es
	pop bp
ret
; this subroutine is for adjusting bottom border if something get wrong
AdjustBottomBorder:
	push ax
	push di
	push cx
	cld
	mov ax, 0x06db ;db is ascii for box
	mov di, 3840 ; starting address of last line
	mov cx ,80
	repne stosw
	pop cx
	pop di
	pop ax
ret
; start of clearCharacterFromOld_Loc, takes no argument and return nothing this is used when i move character and i need to delete from its orignal position
clearCharacterFromOld_Loc:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push es
	push di
	
	mov ax, [charXcoordinate] 
	push ax ; push x position 
	mov ax, [charYcoordinate]
	push ax ; push y position 
	mov ax, 0xE
	push ax ; push attribute 
	mov ax,  CharacterBodyDeleted
	push ax ; push address of message 
	call printString ; welcome to endless runner game will print here
	
	
	pop di
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret

gamePlayEnvironment:
	push bp
	mov bp, sp
	push es
	push di
	push ax
	push bx 
	push dx
	push cx
	
	xor di, di
	mov ax, 0xb800
	mov es, ax
	
	; section that will remain static for whole gameplay
	mov ax, 0x07db ;de is ascii of vertical rectangle
	; vertical left track and right lines
	mov cx, 23
	mov dx, 270; point di to 2nd line
	
	AsideSectionOuterLoop:
		mov cx , 23
		mov di , dx
		AsideScoreSection:
			mov [es:di], ax
			add di, 160
		loop AsideScoreSection
		add dx , 2
		cmp dx, 318
	jne AsideSectionOuterLoop
	
	restart:  ; control will come here every time collision happen or for 1st time of program execution
	call displayCharacter
	;mov cx, 30
	;Sections that will change with gameplay score character life etc
	
	outerMovementStarting:
	mov cx, [gameMode] ; hard mode or easy mode ; 2 for easy mode and 1 for hard mode
	
	call generateRandomObstacle
	push cx
	fixObstacleQuantity:
	
	call checkIfLifeZero
	call printRemainingLife
	call printScore ; also contain increment of score
	; for managing generation of random obstacle create a random number that is 1-49 if number is between 1-10 then generate obstacle else do not generate 

	call MoveObstaclesDown
	call moveCharacter
	call checkIfCollision   	; if collision occur ax will have value of 1 else ax will be 0
	loop fixObstacleQuantity
	pop cx
	call delay
	call delay
	call delay
	call delay
	call scoreIncrement
	jmp outerMovementStarting
	
	
	pop cx
	pop dx
	pop bx
	pop ax
	pop di
	pop es
	pop bp
	ret
	GameOverScreen:
	push bp
	mov bp, sp
	push ax
	
	mov ax, 34 
	push ax ; push x position 
	mov ax, 10
	push ax ; push y position 
	mov ax,  0x84  
	push ax ; push attribute 
	mov ax,  gameOverString
	push ax ; push address of message 
	call printString ; welcome to endless runner game will print here
	
	mov ax, 31 
	push ax ; push x position 
	mov ax, 14
	push ax ; push y position 
	mov ax, 0x2  
	push ax ; push attribute 
	mov ax,  yourScoreString
	push ax ; push address of message 
	call printString ; welcome to endless runner game will print here
	
	mov ax, 44
	push ax ; push x position 
	mov ax, 14
	push ax ; push y position 
	mov ax, 0x2 
	push ax ; push attribute 
	
	mov ax, [scores]
	push ax ; place number on stack 
	
	call printAnyNumber
	
	
	
	pop ax
	pop bp
	ret
; start of checkIfCollision takes no parameter , return 1 in ax if collision occur and also decrement life by 1
checkIfCollision:
	push bp
	mov bp, sp
	push es
	push di
	push dx
	push bx
	push cx
	xor cx ,cx
	xor bx, bx
	mov bx, [charXcoordinate] ; take x coordinate
	mov cx, [charYcoordinate] ; take y coordinate
	; now take value from x and y coordinate
	; i need to check collition if x value of OBSTACLE is = x of char and y value of OBSTACLE = y-1 of char
	; calcuate location y-1 then check if it is $ at x , x+1, x+2 , x+3
	mov ax , 0xb800
	mov es, ax
	
	xor ax, ax
	mov al, 80 ; load al with columns per row 
	sub cx, 1 ; decrement value of cx by 1 so that it checks above character poition
	mul cx ; multiply with y position 
	add ax, bx ; add x position 
	shl ax, 1 ; turn into byte offset 
	mov di,ax ; point di to required location
	; now di is pointing to y-1 of character position
	; now i should compare di position with '$'
	checkHasCollision:
	mov al, '$'
	cmp al, [es:di] ; for char "("
	je haveCollision
	add di, 2 ;; for next char "0"
	cmp al, [es:di]
	je haveCollision
	add di, 2 ;; for next char "_"
	cmp al, [es:di]
	je haveCollision
	add di, 2 ;; for next char "0"
	cmp al, [es:di]
	je haveCollision
	add di, 2 ;; for next char ")"
	cmp al, [es:di]
	je haveCollision
	jmp noCollisionOccured
	haveCollision:
	mov ax, [life] ; mov current life in ax
	sub ax, 1 ; subtract by 1
	mov word [life], ax ; update LIFE
;	cmp ax , 0
;
	jmp startofGame ;; temperory doing this
	noCollisionOccured:
	
	pop cx
	pop bx
	pop dx
	pop di
	pop es
	pop bp
	ret
	
;start of printRemainingLife
;this subroutine takes no parameter
printRemainingLife:
	push bp
	mov bp, sp
	push es
	push di
	push ax
	push bx 
	push dx
	push cx
	
	; print lives and scores of game
	mov ax, 56 
	push ax ; push x position 
	mov ax, 8
	push ax ; push y position 
	mov ax, 0xE  
	push ax ; push attribute 
	mov ax,  remainingLife
	push ax ; push address of message 
	call printString ; Remaining life will print
	
	mov ax, 69
	push ax ; push x position 
	mov ax, 8
	push ax ; push y position 
	mov ax, 0x0E
	push ax ; push attribute 
	
	mov ax, [life]
	push ax ; place number on stack 
	
	call printAnyNumber
	
	pop cx
	pop dx
	pop bx
	pop ax
	pop di
	pop es
	pop bp
	ret 

printScore:
	push bp
	mov bp, sp
	push es
	push di
	push ax
	push bx 
	push dx
	push cx
	
	; print lives and scores of game
	mov ax, 56 
	push ax ; push x position 
	mov ax, 10
	push ax ; push y position 
	mov ax, 0xE  
	push ax ; push attribute 
	mov ax,  ScoreString
	push ax ; push address of message 
	call printString ; Remaining life will print
	
	mov ax, 65
	push ax ; push x position 
	mov ax, 10
	push ax ; push y position 
	mov ax, 0x0E
	push ax ; push attribute 
	
	mov ax, [scores]
	push ax ; place number on stack 
	
	call printAnyNumber
	
	
	
	pop cx
	pop dx
	pop bx
	pop ax
	pop di
	pop es
	pop bp
	ret 

;moveCharacter moves character , takes no argument return nothing just check arrow key is pressed and change location accordingly
moveCharacter:
	push ax ; for inturrupt
	push dx ; for location changing
	mov ah,01 ; keypress service to check if any keypressed if yes then check for which key pressed
    int 16h ; keyboard interupt
	jz noKEY
	call clearCharacterFromOld_Loc ; clear character from old location
	mov ah, 0
	int 16h
    cmp ah,0x48 ;up arrow
	je moveUp
    cmp ah,0x4B ;left arrow
    je moveLeft
    cmp ah,0x4D ;right arrow
    je moveRight
	cmp ah,0x50 ;down arrow
    je moveDown
	
	moveUp:
		mov dx, [charYcoordinate]
		sub dx ,1
		cmp dx, word [MIN_Y_COORDINATE]
		je skipUp
		mov word [charYcoordinate], dx
		skipUp:
		jmp noKEY

	moveDown:
		mov dx, [charYcoordinate]
		add dx, 1
		cmp dx,word [MAX_Y_COORDINATE]
		je skipDown
		mov word [charYcoordinate], dx
		skipDown:
		jmp noKEY

	moveLeft:
		mov dx, [charXcoordinate]
		sub dx, 1
		cmp dx, word [MIN_X_COORDINATE]
		je skipLeft
		mov word [charXcoordinate], dx
		skipLeft:
		jmp noKEY

	moveRight:
		mov dx, [charXcoordinate]
		add dx, 1
		cmp dx, word [MAX_X_COORDINATE]
		je skipRight
		mov word [charXcoordinate], dx
		skipRight:
	noKEY:
	call displayCharacter ; display character on new location
	pop dx
	pop ax
ret

	; start of checkIfLifeZero takes no parameter and return nothing
checkIfLifeZero:
	push ax
	push bx	
	mov ax, [life]
	cmp ax, 0
	je endofGame
	pop bx
	pop ax
	ret
start:
	call clrscr
	call drawborder
	call PrintWelcomeScreen
	; after pressing any key from PrintWelcomeScreen 
	call clrscr
	; now display game enviroment
	call drawborder
	call printGameMode
	call loadingAnimation
	startofGame:
	call clrscr
	call drawborder
	call gamePlayEnvironment
endofGame:
	call clrscr
	call GameOverScreen
	call drawborder
	; wait for keypress
	mov ah , 0x1 ; input char is 0x1 in ah
	mov ah , 0x1 ; 
	int 21h
	mov ax, 0x4c00
	int 0x21

; Change mode subroutine , takes no argument and returns nothing

printGameMode:
	push bp
	mov bp, sp
	push ax
	push dx
	
	mov ax, 18 
	push ax ; push x position 
	mov ax, 8
	push ax ; push y position 
	mov ax, 0xE  
	push ax ; push attribute 
	mov ax,  gameModeString
	push ax ; push address of message 
	call printString ; welcome to endless runner game will print here
	xor ax , ax
	mov ah , 0
	int 0x16
	cmp ah,0x48 ;up arrow
	jz easyModeLABEL
	mov word[gameMode] , 1
	mov word[life], 1
	jmp endOfGAMEMODE
	easyModeLABEL:
	mov word[gameMode], 2
	mov word[life] , 3
	endOfGAMEMODE:

	pop dx
	pop ax
	pop bp
	ret

