		

;************************************************************************
	THUMB	
	REQUIRE8
	PRESERVE8
;************************************************************************

	include REG_UTILES.inc


;************************************************************************
; 					IMPORT/EXPORT Système
;************************************************************************

	IMPORT ||Lib$$Request$$armlib|| [CODE,WEAK]
	
	IMPORT Allume_LED
    IMPORT Eteint_LED
	IMPORT OldEtatUn	  
	IMPORT OldEtatZero
	IMPORT ChangementLED

	IMPORT DriverGlobal
	IMPORT DriverReg
	IMPORT DriverPile
	IMPORT Tempo
	
	IMPORT Bleu
	IMPORT Blanc
	IMPORT Rouge
	IMPORT PBleu
	IMPORT PBlanc
	IMPORT PRouge
	IMPORT France


; IMPORT/EXPORT de procédure           

	IMPORT Init_Cible
	

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite

OldEtat DCW 0x00
	EXPORT OldEtat

N 		equ 500
	EXPORT N

	;IMPORT DataSend

;*******************************************************************************
	
	AREA  moncode, code, readonly


			

		
		

		


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************

		MOV R0,#1
		
		BL Init_Cible ;Init_cible(1)
		
		MOV R4, #N

;BoucleReg
;		LDR R6, = Bleu
;		BL DriverReg
;	
;		BL Tempo
;		
;		LDR R6, = Blanc
;		BL DriverReg
;		
;		BL Tempo
;		
;		LDR R6, = Rouge
;		BL DriverReg
;		
;		BL Tempo
;		
;		LDR R6, = PBleu
;		BL DriverReg
;		
;		BL Tempo
;		
;		LDR R6, = PBlanc
;		BL DriverReg
;		
;		BL Tempo
;		
;		LDR R6, = PRouge
;		BL DriverReg
;		
;		BL Tempo
;		
;		LDR R6, = France
;		BL DriverReg
;		
;		BL Tempo
;		BL Tempo
;		BL Tempo

;		B BoucleReg
; Meme boucle réalisée ci-dessous mais en utilisant DriverReg		
		
		
		
		
BouclePile

		LDR R9, = Bleu
		PUSH {R9}
		BL DriverPile		
		ADD SP, #4
	
		BL Tempo
		
		LDR R9, = Blanc
		PUSH {R9}
		BL DriverPile		
		ADD SP, #4
		
		BL Tempo
		
		LDR R9, = Rouge
		PUSH {R9}
		BL DriverPile		
		ADD SP, #4
		
		BL Tempo
		
		LDR R9, = PBleu
		PUSH {R9}
		BL DriverPile		
		ADD SP, #4
		
		BL Tempo
		
		LDR R9, = PBlanc
		PUSH {R9}
		BL DriverPile		
		ADD SP, #4
		
		BL Tempo
		
		LDR R9, = PRouge
		PUSH {R9}
		BL DriverPile		
		ADD SP, #4
		
		BL Tempo
		
		LDR R9, = France
		PUSH {R9}
		BL DriverPile		
		ADD SP, #4
		
		BL Tempo
		BL Tempo
		BL Tempo

		
		BL Tempo
		
		B BouclePile
		
;		;Tantque(vrai)
;		;rien Faire ; boucle infinie terminale
;		
		B .			 ; boucle inifinie terminale...
					; Pour bien observer la fin du programme et s'y arreter /

		ENDP

	END

;*******************************************************************************
