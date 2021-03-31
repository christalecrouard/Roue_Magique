		

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
	IMPORT Tempo
	IMPORT Barrette1


; IMPORT/EXPORT de procédure           

	IMPORT Init_Cible
	

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite

OldEtat DCW 0x00
	EXPORT OldEtat

N 		equ 10


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
		
		mov R4, #N
		
		BL Tempo
		
		LDR R6, = Barrette1
		
		;LDRSH R11, [R8]
		
		BL DriverGlobal
		
;		;Tantque(vrai)
;		;rien Faire ; boucle infinie terminale
;		
		B .			 ; boucle inifinie terminale...
					; Pour bien observer la fin du programme et s'y arreter /

		ENDP

	END

;*******************************************************************************
