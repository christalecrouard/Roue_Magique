		

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
	IMPORT Barrette1


; IMPORT/EXPORT de procédure           

	IMPORT Init_Cible
	

	EXPORT main
	
;*******************************************************************************


;*******************************************************************************
	AREA  mesdonnees, data, readwrite

OldEtat DCW 0x00
	EXPORT OldEtat

N 		DCB 10

;*******************************************************************************
	
	AREA  moncode, code, readonly


			

		
		

		


;*******************************************************************************
; Procédure principale et point d'entrée du projet
;*******************************************************************************
main  	PROC 
;*******************************************************************************

		MOV R0,#0
		
		BL Init_Cible ;Init_cible(0)
		
		;BL Eteint_LED
		;MOV R7, #0
		
		LDR R8, = OldEtat
		LDRSH R11, [R8]
		
		
		LDR R0, = GPIOBASEA
		LDR R9, [R0, #OffsetInput]

		MOV R4, #0	; Compteur initialisé à 0
		LDR R0, = N ; Nombre de Passage 
		LDRSH R5, [R0]
	
	
		;if oldetat == 0 et capteur == 1 => front montant
		;si front montant et led == 0 => led =1
		;else if front montant et led ==1 => led = 0


Tantque CMP R4, R5			; Comparaison du compteur pour choisir d'entrer dans ou de passer la boucle
		BGT SortieBoucle	; Sortie de la boucle si le compteur atteint le nombre

		LDR R0, = GPIOBASEA
		LDR R9, [R0, #OffsetInput]	; Initialisation du capteur
		
si      TST R9, #(0x1 << 8)	; Bit à 1 si le capteur ne détecte pas la présence de l’aimant.
		BEQ Sinon

alors	CMP R11, #0x01		; Si OldEtat = 1 on sort du Si : il n'y a pas de changement
		BEQ Sortie	  

		BL OldEtatUn		; Variable OldEtat passe à 1
		ADD R4, #1			; Incrémente le compteur
		BL ChangementLED	; Changement Etat LED

		B Sortie			

Sinon 	BL OldEtatZero		; Variable OldEtat passe à 0	
		
Sortie	B Tantque

SortieBoucle
		BL Allume_LED	; LED reste allumée à la fin de la boucle
		
;		;Tantque(vrai)
;		;rien Faire ; boucle infinie terminale
;		
		B .			 ; boucle inifinie terminale...
					; Pour bien observer la fin du programme et s'y arreter /

		ENDP

	END

;*******************************************************************************
