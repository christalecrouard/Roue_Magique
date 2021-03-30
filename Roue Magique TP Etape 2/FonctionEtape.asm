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
		IMPORT Barrette1


		IMPORT OldEtat

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
	POP {R1,R2}
	;Set SCLK
	LDR R1, = GPIOBASEA
	MOV R2, #(0x01 << 5)
	STRH R2, [R1, #OffsetSet] ; sur le mod�le de ce qui a �t� fait en �tape 1 : mise � 1 de SCLK
	
	;1-Pour NbLed = 1 � 48
For1
		;(ValCourante)8 ? Barette1[NbLed]
		;(ValCourante)32 ? (ValCourante)8 << 24 
		
		;2-Pour NbBit = 1 � 12
For2
			;Reset(SCLK)
			LDR R1, = GPIOBASEA
			MOV R2, #(0x01 << 5)
			STRH R2, [R1, #OffsetReset]
			
			;Si (PF((ValCourante)32) = 1) ; PF indique le bit poids fort de la valeur
				;Set(Sin)
			;Sinon 
				;ReSet(Sin)
			;FinSi
			
			;ValCourante)32 ? (ValCourante)32 << 1 ; on positionne le bit suivant
			
			;Set(SCLK)
			LDR R1, = GPIOBASEA
			MOV R2, #(0x01 << 5)
			STRH R2, [R1, #OffsetSet]
			
		;2-FinPour
	;1-FinPour
FinFor1

	;Reset SCLK
	LDR R1, = GPIOBASEA
	MOV R2, #(0x01 << 5)
	STRH R2, [R1, #OffsetReset]
	
	;Datasend prend 0
	
	
	BX LR
	ENDP


Allume_LED PROC 
		PUSH {LR}
		
		; pour allumer la LED avec le registre SET
		;(PortB.Set)16= <- (0x01 << 10)
		;mettre le bit 10 de SET � 1
		LDR R1, = GPIOBASEB
		
		MOV R2, #(0x01 << 10)
		STRH R2, [R1, #OffsetSet]
		
		
		POP {LR}
		BX LR
		ENDP
			
Eteint_LED PROC 
		PUSH {LR}
		; pour �teindre la LED avec le registre RESET
		;(PortB.Reset)16= <- (0x01 << 10)
		LDR R1, = GPIOBASEB
		
		MOV R2, #(0x01 << 10)
		STRH R2, [R1, #OffsetReset]
		
		POP {LR}
		BX LR
		ENDP
			
OldEtatUn PROC
		;Pour mettre la variable OldEtat � 1
		LDR R8, = OldEtat
		LDRSH R11, [R8]
		MOV R11, #0x01
		STRH R11, [R8] ;OldEtat � 1
		
		BX LR
		ENDP
			
OldEtatZero PROC
		;Pour mettre la variable OldEtat � 0
		LDR R8, = OldEtat
		LDRSH R11, [R8]
		MOV R11, #0x00
		STRH R11, [R8] ;OldEtat � 0
		
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
		; pour �teindre la LED avec le registre output
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
	
SiLED 	CMP R7, #1
		BEQ SinonLED
		
		PUSH {LR}
		BL Allume_LED	; pour allumer la LED avec le registre SET
		MOV R7, #1
		B SortieLED
		
SinonLED 
		PUSH {LR}
		BL Eteint_LED	; pour �teindre la LED avec le registre RESET
		MOV R7, #0

SortieLED
		POP {LR}
		BX LR
		ENDP
			
;########################################################################
; Proc�dure ????
;########################################################################
;
; Param�tre entrant  : ???
; Param�tre sortant  : ???
; Variables globales : ???
; Registres modifi�s : ???
;------------------------------------------------------------------------







;**************************************************************************
	END