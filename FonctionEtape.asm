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





;########################################################################
; Procédure ????
;########################################################################
;
; Paramètre entrant  : ???
; Paramètre sortant  : ???
; Variables globales : ???
; Registres modifiés : ???
;------------------------------------------------------------------------

	; pour allumer la LED avec le registre SET
	;(PortB.Set)16= <- (0x01 << 10)
	;mettre le bit 10 de SET à 1
		
Allume_LED PROC
	LDR R1, = GPIOBASEB
	MOV R2, #(0x01 << 10)
	STRH R2, [R1, #OffsetSet]
	BX LR
	ENDP

	; pour éteindre la LED avec le registre RESET
	;(PortB.Reset)16= <- (0x01 << 10)
Eteint_LED PROC
	MOV R2, #(0x01 << 10)
	STRH R2, [R1, #OffsetReset]
	BX LR
	ENDP

		; pour allumer la LED avec le registre output
		;Etat_PortB = <- (PortB.Output)16
		;Etat_PortB = (Etat_PortB) ou (0x01 << 10)
		;(PortB.Output)16 = <- Etat_PortB
			;LDRH R3, [R1, #OffsetOutput]
			;ORR R4, R3, R2
			;STRH R4,  [R1, #OffsetOutput]
		
		; pour éteindre la LED avec le registre output
		;Etat_PortB = <- (PortB.Output)16
		;Etat_PortB = (Etat_PortB) et not((0x01 << 10))
		;(PortB.Output)16 = <- Etat_PortB
			;LDRH R3, [R1, #OffsetOutput]
			;MOV R2, #(0x01 << 10)
			;MVN R5, R2
			;AND R4, R3, R5
			;STRH R4, [R1, #OffsetOutput]

;**************************************************************************
	END