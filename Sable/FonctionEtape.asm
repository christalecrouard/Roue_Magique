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
	EXPORT Allume_led
	EXPORT Eteind_led
	EXPORT DriverGlobal
	EXPORT DriverPile
	EXPORT Tempo
	EXPORT Copie
	IMPORT Barrette1
	IMPORT DataSend
	IMPORT Barrette2
	IMPORT mire
	EXPORT table
	EXPORT Int_time_led
	EXPORT Int_time_sect
	IMPORT OLDETAT
	EXPORT Int_time1_up
	EXPORT Int_time4_up
	IMPORT Run_Timer4;
	IMPORT Stop_Timer4;	
	EXPORT secteur
;**************************************************************************



;***************CONSTANTES*************************************************

	include REG_UTILES.inc 

;**************************************************************************
	

;***************VARIABLES**************************************************
	 AREA  MesDonnees, data, align=9, readwrite
table	SPACE 1024;
time4_etat DCB 0x0
nb_time_sect DCB 0x0;
nb_sect DCB 0X8;
secteur DCD 0x0
compteur DCB 0x1;
;**************************************************************************



;**************************************************************************



;***************CODE*******************************************************
   	AREA  moncode, code, readonly
;**************************************************************************

Allume_led PROC
		PUSH{R0,R2}
		LDR R2,=GPIOBASEB+OffsetSet ;set
		MOV R0,#0x01<<10
		STRH R0,[R2]
		POP{R0,R2}
		BX LR
		ENDP
			
Eteind_led PROC
		PUSH{R0,R2}
		LDR R2,=GPIOBASEB+OffsetReset ;reset
		MOV R0,#0x01<<10
		STRH R0,[R2]
		POP{R0,R2}
		BX LR
		ENDP


Int_time_led PROC
		PUSH{R8,R9,R10,LR};
		
		LDR R9,=GPIOBASEA+OffsetInput
		LDR R10,[R9]
		AND R10,#0x0100
		
Si_time1		CMP R10,#0x0100
		BNE Sinon_time1
		
Alors_time1	BL Eteind_led
		B Sortie_time1
		
Sinon_time1	BL Allume_led
Sortie_time1
		MOV R10,#0xFFFD
		LDR R9,=TIM1_SR
		LDR R8,[R9]
		ADD R8,R10
		STR R8,[R9]
		POP{R8,R9,R10,LR};
		BX LR 
		ENDP






Int_time_sect PROC
	PUSH{R0,R1,R2,LR}
	LDR R0,=TIM1_CNT
	LDR R1,[R0]
	LDR R0,=nb_sect
	LDRB R2,[R0]
	LSR R0,R1,R2
	LDR R1,=TIM4_ARR
	STR R0,[R1]
	LDR R0,=nb_time_sect
	LDRB R1,[R0]
	CMP R1,#3
si_sect BLE sinon_sect ;evite les debordement;
	MOV R1,#4
	B sortie_sect
sinon_sect	
	ADD R1,R1,#1 ;compteur du nombre d'interruption time_sect;
sortie_sect	
	STRB R1,[R0]
	BL Run_Timer4
	MOV R0,#0xFFFD
	LDR R1,=TIM1_SR
	LDR R2,[R1]
	AND R2,R0
	STR R2,[R1]
	POP{R0,R1,R2,LR}
	BX LR
	ENDP



Int_time1_up PROC
	
	PUSH{R0,R1,R2,LR}
	LDR R0,=nb_time_sect
	LDRB R1,[R0]
	CMP R1,#3
si_up	BMI sortir_up
	MOV R1,#0;
	STRB R1,[R0]
	BL Stop_Timer4;	
	LDR R0,=time4_etat;
	MOV R1,#0x0
	STRB R1,[R0]
sortir_up
	LDR R0,=TIM1_SR
	LDR R2,[R0]
	MOV R1,#0xFFFE
	AND R2,R1
	STR R2,[R0]
	POP{R0,R1,R2,LR}
	BX LR
	ENDP





DriverGlobal	PROC
		PUSH{R0,R1,R2,R3,R4,R5,R6}
		;on attend la barrette 1 dans R6
		LDR R5,=GPIOBASEA+OffsetSet
		MOV R1,#0x20 
		STRH R1,[R5] ;Set(SCLK)

		MOV R0,#0x0 ;Compteurled
		
ForNB_LED		
		MOV R4,#0x0 ;Compteurbit
		LDRB R2,[R6],#1 ;valcourante8
		LSL R3,R2,#24 ;valcourante32
ForNB_Bit
		LDR R5,=GPIOBASEA+OffsetReset
		MOV R1,#0x20 ;ReSet(SCLK)
		STRH R1,[R5]
		
		AND R5,R3,#0x80000000
SI		CMP R5,#0x80000000
		BNE SINON
		LDR R5,=GPIOBASEA+OffsetSet
		MOV R1,#0x80 ;Set(SIN1)
		STRH R1,[R5]
		B FIN
SINON
		LDR R5,=GPIOBASEA+OffsetReset
		MOV R1,#0x80 ;ReSet(SIN1)
		STRH R1,[R5]
FIN		
		LSL R3,R3,#1
		
		LDR R5,=GPIOBASEA+OffsetSet
		MOV R1,#0x20 
		STRH R1,[R5] ;Set(SCLK)
		
		ADD R4,R4,#1
		CMP R4,#8
		BNE ForNB_Bit
FinNB_Bit		
		ADD R0,#1
		CMP R0,#48
		BLE ForNB_LED
FinNB_LED
		POP{R0,R1,R2,R3,R4,R5,R6}
		BX LR
		ENDP



DriverPile	PROC
	;avant l'appelle on fait : LDR R6,=Barrette1 PUSH{R6}
		PUSH{R7}
		MOV R7,SP
		PUSH{R0,R1,R2,R3,R4,R5,R6}
		LDR R6,[R7,#4]
		LDR R5,=GPIOBASEA+OffsetSet
		MOV R1,#0x20 
		STRH R1,[R5] ;Set(SCLK)

		MOV R0,#0x0 ;Compteurled
		
ForNB_LED2		
		MOV R4,#0x0 ;Compteurbit
		LDRB R2,[R6],#1 ;valcourante8
		LSL R3,R2,#24 ;valcourante32
ForNB_Bit2
		LDR R5,=GPIOBASEA+OffsetReset
		MOV R1,#0x20 ;ReSet(SCLK)
		STRH R1,[R5]
		
		AND R5,R3,#0x80000000
SI2		CMP R5,#0x80000000
		BNE SINON
		LDR R5,=GPIOBASEA+OffsetSet
		MOV R1,#0x80 ;Set(SIN1)
		STRH R1,[R5]
		B FIN2
SINON2
		LDR R5,=GPIOBASEA+OffsetReset
		MOV R1,#0x80 ;ReSet(SIN1)
		STRH R1,[R5]
FIN2		
		LSL R3,R3,#1
		
		LDR R5,=GPIOBASEA+OffsetSet
		MOV R1,#0x20 
		STRH R1,[R5] ;Set(SCLK)
		
		ADD R4,R4,#1
		CMP R4,#8
		BNE ForNB_Bit2
FinNB_Bit2		
		ADD R0,#1
		CMP R0,#48
		BLE ForNB_LED2
FinNB_LED2
		LDR R5,=GPIOBASEA+OffsetReset
		MOV R1,#0x20 ;ReSet(SCLK)
		STRH R1,[R5]
		POP{R0,R1,R2,R3,R4,R5,R6}
		BX LR
		ENDP





Tempo	PROC
	;on attend le nombre de miliseconde dans R0;
	PUSH{R0}
	
For_tempo
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	SUB R0,R0,#1
	CMP R0,#0
	BNE For_tempo
	
	POP{R0}
	BX LR
	
	ENDP




Copie	PROC
		
		PUSH{R0,R1,R2,LR}
		MOV R2,#0X00
boucle_cop	LDRB R1,[R2],#1
		STRB R1,[R0],#1
		CMP R2,#1024
		BNE boucle_cop
		
		LDR R2,=SCB_VTOR;
		LDR R0,=table
		STR R0,[R2]
		POP{R0,R1,R2,LR}
		
		BX LR
		ENDP
	



Int_time4_up PROC
	PUSH{LR}
	PUSH{R5,R6,R7,R8,R9,R10}
	LDR R5,=secteur
	LDR R6,[R5]
	BL DriverGlobal ;ce programme attend une adresse sur R6
	ADD R7,R6,#16*3
	STR R7,[R5]
	
	LDR R8,=compteur
	LDR R6,[R8]
	
Si_t4	CMP R6,#8
	BNE sortie_t4
ALORs_t4
	MOV R6,#0
	LDR R9,=mire
	STR R9,[R5]
sortie_t4
	ADD R6,#1
	STR R6,[R8]
	MOV R10,#0xFFFE
	LDR R9,=TIM4_SR
	LDR R8,[R9]
	AND R8,R10
	STR R8,[R9]
	POP{R5,R6,R7,R8,R9,R10}
	POP{LR}
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