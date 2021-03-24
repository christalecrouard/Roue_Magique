		

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




; IMPORT/EXPORT de procédure           

	IMPORT Init_Cible
	IMPORT Allume_LED
	IMPORT Eteint_LED

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite



;*******************************************************************************
	
	AREA  moncode, code, readonly

		
;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************


			
		
		MOV R0,#0
		
		BL Init_Cible;
		;Init_cible(0)
		
		LDR R1, = GPIOBASEB
		
		LDR R3, = GPIOBASEA
		LDR R4, [R3, #OffsetInput]
		
Tantque
		
		TST R4, #0x0000102; capteur
		BNE FinDuSi1
		BL Allume_LED
FinDuSi1
		
		TST R4, #0; capteur
		B FinDuSi2
		BL Eteint_LED
FinDuSi2

		B Tantque
		
		
		;Tantque(vrai)
		;rien Faire ; boucle infinie terminale
		
		B .			 ; boucle inifinie terminale...


		ENDP

	END

;*******************************************************************************
