		

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
	IMPORT Allume_led
	IMPORT Eteind_led
	IMPORT Tempo
	EXPORT main
	IMPORT Copie
	IMPORT Barrette1
	IMPORT DriverGlobal
	IMPORT DriverPile
	IMPORT DataSend
	IMPORT Barrette2
	IMPORT mire
	IMPORT table
	EXPORT OLDETAT
	IMPORT Int_time_led
	IMPORT Int_time_sect
	IMPORT Int_time1_up
	IMPORT Int_time4_up
	IMPORT Run_Timer1;
	IMPORT Run_Timer4;
	IMPORT Stop_Timer4;	
	IMPORT secteur;
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite

OLDETAT DCD 0x0100
	
;*******************************************************************************
	
	AREA  moncode, code, readonly
		


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************
	MOV R0,#2;
	
	BL Init_Cible;
	
	LDR R0, =table;
	BL Copie;
	
	LDR R0,=table+16*4+27*4;pour aller a l'interuption 27
	LDR R1,=Int_time_sect;
	STR R1,[R0]
	
	LDR R0,=table+16*4+25*4;pour aller a l'interuption 25
	LDR R1,=Int_time1_up;
	STR R1,[R0]
	
	LDR R0,=table+16*4+30*4;pour aller a l'interuption 30
	LDR R1,=Int_time4_up;
	STR R1,[R0]
	
	;initialisation secteur
	LDR R0,=secteur
	LDR R1,=mire
	STR R1,[R0]
	
	BL Run_Timer1;
	;apres ca on commence a faire des chose;
	
	;BL Run_Timer4;
	
		
Boucle_tot	
	
	B Boucle_tot

	
	ENDP
	END


;*******************************************************************************
