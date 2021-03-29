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
Allume_LED PROC 
		PUSH {LR}
		
		; pour allumer la LED avec le registre SET
		;(PortB.Set)16= <- (0x01 << 10)
		;mettre le bit 10 de SET à 1
		LDR R1, = GPIOBASEB
		
		MOV R2, #(0x01 << 10)
		STRH R2, [R1, #OffsetSet]
		
		
		POP {LR}
		BX LR
		ENDP
			
Eteint_LED PROC 
		PUSH {LR}
		; pour éteindre la LED avec le registre RESET
		;(PortB.Reset)16= <- (0x01 << 10)
		LDR R1, = GPIOBASEB
		
		MOV R2, #(0x01 << 10)
		STRH R2, [R1, #OffsetReset]
		
		POP {LR}
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
	
SiLED 	CMP R7, #1
		BEQ SinonLED
		
		PUSH {LR}
		BL Allume_LED	; pour allumer la LED avec le registre SET
		MOV R7, #1
		B SortieLED
		
SinonLED 
		PUSH {LR}
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