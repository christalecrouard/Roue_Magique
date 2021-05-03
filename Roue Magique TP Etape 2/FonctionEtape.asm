;***************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8

;**************************************************************************
;  Fichier Vierge.asm
; Auteur : V.MAHOUT
; Date :  12/11/2013
;**************************************************************************

;***************IMPORT/EXPORT**********************************************
		EXPORT Allume_LED
		EXPORT Eteint_LED
		EXPORT OldEtatUn	  
		EXPORT OldEtatZero
		EXPORT ChangementLED
			
			
		EXPORT DriverGlobal
		EXPORT Tempo
		IMPORT Blanc
		EXPORT DriverReg
		EXPORT DriverPile

		IMPORT OldEtat
		IMPORT DataSend
		IMPORT N
			
		

;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc 

;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite
;**************************************************************************


;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************

DriverGlobal PROC
		PUSH {R1,R2,R3,R4,R5,R6,R7,R8}
		
		MOV R3, #0	;Initilisation du cpteur nbled à 0
		MOV R4, #1	;Initilisation du cpteur nbbit à 0
		LDR R6, = Blanc
		
		;Set SCLK
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetSet] ; sur le modèle de ce qui a été fait en étape 1 : mise à 1 de SCLK
		
	;1-Pour NbLed = 1 à 48
For1	CMP R3, #48	;Mettre en variable globale Nbled
		BGE FinFor1
		
		;(ValCourante)8 <- Barette1[NbLed]
		LDRB R5,[R6,R3]
		
		;(ValCourante)32 <- (ValCourante)8 << 24 
		LSL R7,R5,#24
			
		;2-Pour NbBit = 1 à 12
For2	CMP R4, #12 ;Mettre en variable globale NbBit
		BGE FinFor2
		
		;ValCourante)32 ? (ValCourante)32 << 1 ; on positionne le bit suivant
		LSLS R7,R7,#1
		
			;Reset(SCLK)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetReset]
		
	;Si (PF((ValCourante)32) = 1) ; PF indique le bit poids fort de la valeur
Sid	BCC Sinon
		
		;Set(Sin)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 7)
		STRH R2, [R1, #OffsetSet]
		B FinSid
	
		
Sinon	;Sinon 	
				
		;ReSet(Sin)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 7)
		STRH R2, [R1, #OffsetReset]
	
		
FinSid	;FinSi			
				
				
		;Set(SCLK)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetSet]
			
		;2-FinPour	
		ADD R4,R4,#1	
		B For2

FinFor2		
		;1-FinPour
		MOV R4, #0
		ADD R3,R3,#1
		B For1

FinFor1		

		;Reset SCLK
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetReset]
		
		;Datasend prend 0
		MOV R1,#0
		LDR R8,=DataSend
		STRB R1,[R8]
		
		POP {R1,R2,R3,R4,R5,R6,R7}
		BX LR
		ENDP



Tempo PROC
	
		PUSH {R1,R2,R3,R4,R5,R6}
		MOV R1, #0
		MOV R2, #0
		MOV R3, #10
		LDR R6,= N
		MUL R5, R4,R3 ;R5 prend N fois 10

ForT	CMP R1, R5
		BGT FinForT
		
ForT2	CMP R2, R6	;Mettre en variable globale Nbled
		BGT FinForT2
		NOP
		NOP
		NOP
		NOP
			
		ADD R2,R2, #1
		B ForT2
FinForT2 
		MOV R2, #0
		ADD R1,R1, #1
		B ForT
FinForT

		POP {R1,R2,R3,R4,R5,R6}
		BX LR
		ENDP



DriverReg PROC
		PUSH {R1,R2,R3,R4,R5,R6,R7,R8}
		
		MOV R3, #0	;Initilisation du cpteur nbled à 0
		MOV R4, #1	;Initilisation du cpteur nbbit à 0
				; R6 correspond à l'argument Barrette
		
		;Set SCLK
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetSet] ; sur le modèle de ce qui a été fait en étape 1 : mise à 1 de SCLK
		
	;1-Pour NbLed = 1 à 48
For1R	CMP R3, #48	;Mettre en variable globale Nbled
		BGE FinFor1R
		
		;(ValCourante)8 <- Barette1[NbLed]
		LDRB R5,[R6,R3] ;Argument barrette R6
		
		;(ValCourante)32 <- (ValCourante)8 << 24 
		LSL R7,R5,#24
		
		;2-Pour NbBit = 1 à 12
For2R	CMP R4, #12 ;Mettre en variable globale NbBit
		BGE FinFor2R
			
		;ValCourante)32 ? (ValCourante)32 << 1 ; on positionne le bit suivant
		LSLS R7,R7,#1
			
		;Reset(SCLK)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetReset]
			
		;Si (PF((ValCourante)32) = 1) ; PF indique le bit poids fort de la valeur
SidR	BCC SinonR
		
		;Set(Sin)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 7)
		STRH R2, [R1, #OffsetSet]
		B FinSidR
	
SinonR	;Sinon 	
		;ReSet(Sin)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 7)
		STRH R2, [R1, #OffsetReset]
		
FinSidR	;FinSi		
					
		;Set(SCLK)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetSet]
				
		;2-FinPour	
		ADD R4,R4,#1	
		B For2R

FinFor2R	
	
		MOV R4, #0
		ADD R3,R3,#1
		B For1R

FinFor1R	;1-FinPour	

		;Reset SCLK
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetReset]
		
		;Datasend prend 0
		MOV R1,#0
		LDR R8,=DataSend
		STRB R1,[R8]
		
		POP {R1,R2,R3,R4,R5,R6,R7,R8}
		BX LR
		ENDP


DriverPile PROC
		PUSH {R10}
		MOV R10,SP
		PUSH {R1,R2,R3,R4,R5,R6,R7,R8}
		LDR R6, [R10, #4]
		
		MOV R3, #0	;Initilisation du cpteur nbled à 0
		MOV R4, #1	;Initilisation du cpteur nbbit à 0
				; R6 correspond à l'argument Barrette
	
		;Set SCLK
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetSet] ; sur le modèle de ce qui a été fait en étape 1 : mise à 1 de SCLK
	
	;1-Pour NbLed = 1 à 48
For1P	CMP R3, #48	;Mettre en variable globale Nbled
		BGE FinFor1P
	
		;(ValCourante)8 <- Barette1[NbLed]
		LDRB R5,[R6,R3] ;Argument barrette R6
		
		;(ValCourante)32 <- (ValCourante)8 << 24 
		LSL R7,R5,#24
	
		;2-Pour NbBit = 1 à 12
For2P	CMP R4, #12 ;Mettre en variable globale NbBit
		BGE FinFor2P
		
		;ValCourante)32 ? (ValCourante)32 << 1 ; on positionne le bit suivant
		LSLS R7,R7,#1
			
		;Reset(SCLK)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetReset]
				
		;Si (PF((ValCourante)32) = 1) ; PF indique le bit poids fort de la valeur
SidP	BCC SinonP
	
		;Set(Sin)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 7)
		STRH R2, [R1, #OffsetSet]
		B FinSidP
	
SinonP	;Sinon 	
		;ReSet(Sin)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 7)
		STRH R2, [R1, #OffsetReset]
			
FinSidP	;FinSi		
					
		;Set(SCLK)
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetSet]
				
		;2-FinPour	
		ADD R4,R4,#1	
		B For2P

FinFor2P	
		
		MOV R4, #0
		ADD R3,R3,#1
		B For1P

FinFor1P	;1-FinPour	

		;Reset SCLK
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetReset]
		
		;Datasend prend 0
		MOV R1,#0
		LDR R8,=DataSend
		STRB R1,[R8]
		
		POP {R1,R2,R3,R4,R5,R6,R7,R8,R10}
		BX LR
		ENDP
			
			
Allume_LED PROC 
	PUSH {R1,R2}
	
	; pour allumer la LED avec le registre SET
	;(PortB.Set)16= <- (0x01 << 10)
	;mettre le bit 10 de SET à 1
	LDR R1, = GPIOBASEB
	MOV R2, #(0x01 << 10)
	STRH R2, [R1, #OffsetSet]
	
	POP {R1,R2}
	BX LR
	ENDP
		
			
Eteint_LED PROC 
		PUSH {R1,R2}
		; pour éteindre la LED avec le registre RESET
		;(PortB.Reset)16= <- (0x01 << 10)
		LDR R1, = GPIOBASEB
		
		MOV R2, #(0x01 << 10)
		STRH R2, [R1, #OffsetReset]
		
		POP {R1,R2}
		BX LR
		ENDP
			
OldEtatUn PROC
		;Pour mettre la variable OldEtat à 1
		LDR R8, = OldEtat
		LDRSH R11, [R8]
		MOV R11, #0x01
		STRH R11, [R8] ;OldEtat à 1
		
		BX LR
		ENDP
			
OldEtatZero PROC
		;Pour mettre la variable OldEtat à 0
		LDR R8, = OldEtat
		LDRSH R11, [R8]
		MOV R11, #0x00
		STRH R11, [R8] ;OldEtat à 0
		
		BX LR
		ENDP
			

AllumeLEDOutput PROC
	; pour allumer la LED avec le registre output
	;Etat_PortB = <- (PortB.Output)16
	;Etat_PortB = (Etat_PortB) ou (0x01 << 10)
	;(PortB.Output)16 = <- Etat_PortB
		
		LDRH R3, [R1, #OffsetOutput]
		ORR R4, R3, R2
		STRH R4,  [R1, #OffsetOutput]
		
		BX LR
		ENDP
			
EteintLEDOutput PROC
		; pour éteindre la LED avec le registre output
	;Etat_PortB = <- (PortB.Output)16
	;Etat_PortB = (Etat_PortB) et not((0x01 << 10))
	;(PortB.Output)16 = <- Etat_PortB
	
		LDRH R3, [R1, #OffsetOutput]
		MOV R2, #(0x01 << 10)
		MVN R5, R2
		AND R4, R3, R5
		STRH R4, [R1, #OffsetOutput]
		
		BX LR
		ENDP
			
ChangementLED PROC
		PUSH {LR}
SiLED 	CMP R7, #1
		BEQ SinonLED
		
		
		BL Allume_LED	; pour allumer la LED avec le registre SET
		MOV R7, #1
		B SortieLED
		
SinonLED 
		
		BL Eteint_LED	; pour éteindre la LED avec le registre RESET
		MOV R7, #0

SortieLED
		POP {LR}
		BX LR
		ENDP
			
;########################################################################
; Procédure ????
;########################################################################
;
; Paramètre entrant  : ???
; Paramètre sortant  : ???
; Variables globales : ???
; Registres modifiés : ???
;------------------------------------------------------------------------







;**************************************************************************
	END