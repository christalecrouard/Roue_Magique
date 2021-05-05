		

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

	IMPORT Run_Timer1
	IMPORT Stop_Timer1
	IMPORT Mire
	IMPORT CopieTVI

	IMPORT Capteur_Togg
	IMPORT Timer_UP
	IMPORT Timer_UP4
	IMPORT Timer_CC
		
	IMPORT AdrTVI



; IMPORT/EXPORT de procédure           

	IMPORT Init_Cible
	

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite

OldEtat 	DCW 0x00
		EXPORT OldEtat

N 		EQU 500
		EXPORT N

Time_CC	EQU (27+16)
Time_UP	EQU (25+16)
Timer_4		EQU (30+16)

TailleTVI EQU 256
	
		ALIGN 512
TVI		SPACE TailleTVI*4;256 mots

State_LED  	DCB 0
		EXPORT State_LED

Passage_CC 	DCB 0
		EXPORT Passage_CC

Tr		DCW 0
	;IMPORT DataSend

;*******************************************************************************
	
	AREA  moncode, code, readonly


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************

		MOV R0,#2
		
		BL Init_Cible ;Init_cible(2)
		
		LDR R0,= TVI
		BL CopieTVI
		LDR R1,=SCB_VTOR
		STR R0, [R1]


		;On  associe la procedure Capteur_Togg a l'interruption Timer_cc n27
;		LDR R1,=Capteur_Togg
;		ADD R0, #(4 * Timer_CC)
;		STR R1,[R0]
;		

		;On  associe la procedure Capteur a l'interruption Timer_cc n27
		LDR R1,=Timer_CC
		ADD R0, #(4 * Time_CC)
		STR R1,[R0]

		;On  associe la procedure Timer_Up a l'interruption Timer_up n25
		LDR R0,= TVI;
		LDR R1,= Timer_UP
		ADD R0, #(4 * Time_UP)
		STR R1,[R0]

;		On  associe la procedure Timer4 a l'interruption Timer_4 n30
		LDR R0,= TVI;
		LDR R1,= Timer_UP4
		ADD R0, #(4 * Timer_4)
		STR R1,[R0]

		BL Run_Timer1

		B .			 ; boucle inifinie terminale...

		ENDP

	END

;*******************************************************************************
