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
		EXPORT DriverReg
		EXPORT DriverPile

		EXPORT Tempo

		IMPORT OldEtat
		IMPORT DataSend
		IMPORT N
		
		IMPORT Blanc
		IMPORT Mire

		IMPORT Run_Timer4
		IMPORT Stop_Timer4


		IMPORT State_LED
		IMPORT Passage_CC

		EXPORT CopieTVI

		EXPORT Capteur_Togg
		EXPORT Timer_CC
		EXPORT Timer_UP
		EXPORT Timer_UP4

		
		

;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc 

TailleTVI 	EQU 256
			
AdrTVI 		EQU 0x0
			EXPORT AdrTVI
BIT_CLK 	EQU 5
BIT_SIN 	EQU 7
NB_LED		EQU 48
NB_BIT		EQU 12
;**************************************************************************


;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, readwrite


Num_Secteur_Courant DCB 0
Capture		DCD	0
Valcourante DCD 0
PisteMire	DCD 0
	
;**************************************************************************


;**************************************************************************

;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************
Changement_Barette	PROC
		PUSH {LR,R3}

		; si on est sur la dernière barette, on reviens au début
		CMP R7,#8
		BNE Barette
		MOV R7,#0
		
Barette LDR R0,= Mire
		MOV R3, #48
		MLA R0,R7,R3,R0	; R0 prend l'adresse de la barette correspondant à R7

		ADD R7,#1		; incémentation du secteur actuel

		POP {LR,R3}
		BX LR
		ENDP
					

Timer_UP4	PROC
		
		PUSH	{R0, R1, LR}

		BL Changement_Barette		; changement de la barette affiché		
		BL DriverReg				; R0 : adresse de la barette		

		; AQUITEMENT
		LDR R1,=TIM4_SR
		LDR R0,[R1]
		AND R0,#~(0x01)
		STR R0,[R1]
		
		POP	{R0, R1, LR}
		BX	LR
		
		ENDP

;########################################################################
; Procédure It_Capteur
;########################################################################
; Variables globales : Passage_cc, TIM_SR
; Registres modifiés : R0, R1
;------------------------------------------------------------------------


Timer_UP PROC
		
		PUSH {R1, LR}
		
		LDR R0, =Capture		
		MOV R1, #0
		STR	R1, [R0] ;On met à 0 la valeur de Capture
		
		BL	Stop_Timer4
				
		LDR	R0, =TIM1_SR		
		LDR	R1, [R0]
		AND	R1, R1, #0xFFFFFFFE
		STR	R1, [R0];Acquittement de l'interruption en effaçant de bit de rang 0 trouvé dans TIM1_SR
		
		POP	{R1, LR}
		BX LR					
		
		ENDP

;########################################################################
; Procédure It_Capteur
;########################################################################
; Variables globales : Passage_cc
; Registres modifiés : R0, R1
;------------------------------------------------------------------------

Timer_CC	PROC
		
		PUSH	{R1-R3, LR}
		LDR		R0, =Capture		;Capture est notre compteur pour s'assurer que la roue fait bien 3 tours à vitesse suffisante 
		LDR		R1, [R0]
		CMP		R1, #3
		LDR		R2, =PisteMire
		MOV		R3, #0
		STR		R3, [R2]			;On rédemarre la Piste à 0 parce que si on est dans Timer_CC, c'est dû au fait que la roue a fait un tour complet
		BEQ		BonneVitesse		;Si R1 = 3, ça veut dire que la roue a tourné 3 fois, c'est suffisant pour assurer la vitesse radiale constante et faire un bon calcul de TIM4_ARR

		ADD		R1, R1, #1
		STR		R1, [R0]			;Sinon, on augmente 1 à la valeur de Capture
		
		LDR		R0, =TIM1_CNT		
		MOV		R1, #0	
		STR		R1, [R0]			;On redémarre le compteur de TIM1 à 0
		
		LDR		R0, =TIM1_SR		
		LDR		R1, [R0]
		AND		R1, R1, #0xFFFFFFFD
		STR		R1, [R0]			;Acquittement de l'interruption
		
		POP		{R1-R3, LR}
		BX		LR					;Fin de l'interruption
		
BonneVitesse						;Partie de la procedure Timer_CC
		
		LDR		R0,	=TIM1_CNT		
		LDR		R1, [R0]			;Cette valeur correspond à la valeur de Tr (la roue tourne à une vitesse constante)
		LDR		R2, =Nbsecteurs 
		UDIV	R1, R1, R2			;Maintenant on calcule la valeur de Reload
		LDR		R0, =TIM4_ARR
		STR		R1, [R0]
		
		LDR		R0, =TIM1_SR		
		LDR		R1, [R0]
		AND		R1, R1, #0xFFFFFFFD 
		STR		R1, [R0]			;Acquittement de l'interruption en effaçant le bit de rang 1 trouvé dans TIM1_SR
		
		LDR		R0, =TIM1_CNT		
		MOV		R1, #0	
		STR		R1, [R0]			;On redémarre le compteur de TIM1 à 0
		
		BL		Run_Timer4			;Démarrage du Timer4 pour commencer l'affichage des secteurs
		
		POP		{R1-R3, LR}
		BX		LR				
		
		ENDP

;########################################################################
;Procédure Capteur_Togg
;########################################################################
; Variables globales : state_LED
; Registres modifiés : R0, R1
;------------------------------------------------------------------------

Capteur_Togg 	PROC
		PUSH {R0, R1,LR}

		LDR  R0,= State_LED
		LDRB R1, [R0]
		CMP R1, #1
		BNE Si_Off
Si_On		BL Eteint_LED
					
		MOV R1, #0
		STRB R1, [R0]
		B FinSi_LED
									
Si_Off		BL Allume_LED 
		
		MOV R1, #1
		STRB R1, [R0]
					
FinSi_LED	LDR R0,=TIM1_SR
		LDR R1, [R0]
		BIC R1, R1, #0x02; On efface le bit 1 R1=R1 AND NOT(0x02)
		STR R1, [R0]
		
		POP {R0,R1,LR}					
		BX LR
		ENDP

;########################################################################
;Procédure CopieTVI
;########################################################################

CopieTVI	PROC
			PUSH{R0,R1,R2,R3}

			LDR   R1,= AdrTVI  	;R0=@TVI 
			MOV   R2, #0 ;variable cpt	
WhileCopie 	
			LDR   R3, [R1]
			STR	  R3, [R0], #4
			
			ADD	  R1, #4
			ADD	  R2, #1
			
			CMP	  R2, #TailleTVI
			BNE	  WhileCopie 

FinCopie POP{R0,R1,R2,R3}
		BX LR
		ENDP

;########################################################################
; Procédures Driver Global
;########################################################################
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


;########################################################################
; Procédure Tempo
;########################################################################
; Variables globales : -
; Registres modifiés : R0, R1
;------------------------------------------------------------------------

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

;########################################################################
; Procédure DriverReg
;########################################################################
; Variables globales : Passage_cc
; Registres modifiés : R0, R1
;------------------------------------------------------------------------

DriverReg PROC
		PUSH {R1,R2,R3,R4,R5,R0,R7,R8}
		
		MOV R3, #0	;Initilisation du cpteur nbled à 0
		MOV R4, #1	;Initilisation du cpteur nbbit à 0
				; R0 correspond à l'argument Barrette
		
		;Set SCLK
		LDR R1, = GPIOBASEA
		MOV R2, #(0x01 << 5)
		STRH R2, [R1, #OffsetSet] ; sur le modèle de ce qui a été fait en étape 1 : mise à 1 de SCLK
		
	;1-Pour NbLed = 1 à 48
For1R	CMP R3, #48	;Mettre en variable globale Nbled
		BGE FinFor1R
		
		;(ValCourante)8 <- Barette1[NbLed]
		LDRB R5,[R0,R3] ;Argument barrette R6
		
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
		
		POP {R1,R2,R3,R4,R5,R0,R7,R8}
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


;########################################################################
; Procédure Allume_LED
;########################################################################
; Variables globales : GPIOBASEB, #OffsetSet
; Registres modifiés : R1 et R2
;------------------------------------------------------------------------
			
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
		

;########################################################################
; Procédure Eteint_LED
;########################################################################
; Variables globales : GPIOBASEB, #OffsetReset
; Registres modifiés : R1 et R2
;------------------------------------------------------------------------
			
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
	

;########################################################################
; Procédure OldEtatUn
;########################################################################
; Variables globales : OldEtat
; Registres modifiés : R8 et R11
;------------------------------------------------------------------------
		
OldEtatUn PROC
		;Pour mettre la variable OldEtat à 1
		PUSH {R8,R11}

		LDR R8, = OldEtat
		LDRSH R11, [R8]
		MOV R11, #0x01
		STRH R11, [R8] ;OldEtat à 1
		
		POP {R8,R11}
		BX LR
		ENDP

;########################################################################
; Procédure OldEtatZero
;########################################################################
; Variables globales : OldEtat
; Registres modifiés : R8 et R11
;------------------------------------------------------------------------
			
OldEtatZero PROC
		;Pour mettre la variable OldEtat à 0
		PUSH {R8,R11}

		LDR R8, = OldEtat
		LDRSH R11, [R8]
		MOV R11, #0x00
		STRH R11, [R8] ;OldEtat à 0
		
		POP {R8,R11}
		BX LR
		ENDP
			
;########################################################################
; Procédure AllumeLEDOutput
;########################################################################
; Variables globales : OffsetOutput, PortB.Output
; Registres modifiés : R1 à R4
;------------------------------------------------------------------------

AllumeLEDOutput PROC
	; pour allumer la LED avec le registre output
	;Etat_PortB = <- (PortB.Output)16
	;Etat_PortB = (Etat_PortB) ou (0x01 << 10)
	;(PortB.Output)16 = <- Etat_PortB
		PUSH {R1,R2,R3,R4}

		LDRH R3, [R1, #OffsetOutput]
		ORR R4, R3, R2
		STRH R4,  [R1, #OffsetOutput]
		
		PUSH {R1,R2,R3,R4}
		BX LR
		ENDP

;########################################################################
; Procédure EteintLEDOutput
;########################################################################
;
; Paramètre entrant  : PortB.Output
; Paramètre sortant  : PortB.Output
; Variables globales : #OffsetOutput
; Registres modifiés : R1 à R5
;------------------------------------------------------------------------
			
EteintLEDOutput PROC
		; pour éteindre la LED avec le registre output
	;Etat_PortB = <- (PortB.Output)16
	;Etat_PortB = (Etat_PortB) et not((0x01 << 10))
	;(PortB.Output)16 = <- Etat_PortB
		PUSH {R1,R2,R3,R4,R5}

		LDRH R3, [R1, #OffsetOutput]
		MOV R2, #(0x01 << 10)
		MVN R5, R2
		AND R4, R3, R5
		STRH R4, [R1, #OffsetOutput]

		POP {R1,R2,R3,R4,R5}
		BX LR
		ENDP

;########################################################################
; Procédure ChangementLED
;########################################################################
;
; Paramètre entrant  : Nombre d'alternattions
; Paramètre sortant  : -
; Variables globales : -
; Registres modifiés : R7 et LR
;------------------------------------------------------------------------
		
ChangementLED PROC
		PUSH {R7,LR}
SiLED 		CMP R7, #1
		BEQ SinonLED		
		BL Allume_LED	; pour allumer la LED avec le registre SET
		MOV R7, #1
		B SortieLED
SinonLED 
		BL Eteint_LED	; pour éteindre la LED avec le registre RESET
		MOV R7, #0
SortieLED
		POP {R7,LR}
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