ORG 00H
RS 	EQU P3.0
RW 	EQU P3.1
E 	EQU P3.2
D1	EQU 40H
D2	EQU 41H
SIGN	EQU 42H
R	EQU 43H
HB	EQU 44H
FB	EQU 45H
RSIGN	EQU 46H
TEMP	EQU 47H
DF	BIT 01H
SF	BIT 02H
EF	BIT 03H
ZF	BIT 04H



MOV SP,#70H
MOV PSW,#00H

		

MAIN: 		LCALL	CLR_MEMORY
		LCALL	LCD_IN
		LCALL	INPUT
		LCALL	CALCULATION
		LCALL	OUTPUT
		AJMP	MAIN
	
	
CLR_MEMORY:
		CLR A
		MOV R1, #40H
		MOV R6, #8
	
	REPEAT:	MOV @R1, A
		INC R1
		DJNZ R6, REPEAT
		CLR 	C
		CLR 	DF
		CLR 	SF
		CLR 	EF
		CLR 	ZF
		MOV R1, #00H
		RET


LCD_IN: 	MOV A,#38H
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#0FH
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#01H
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#80H
		ACALL COMNWRT
		ACALL DELAY
		MOV A,#06H
		ACALL COMNWRT
		ACALL DELAY
		RET

INPUT:		
	IP1:	ACALL 	KEYPAD							
		ACALL 	INPUT_CHECK							
		JB	EF,ERROR						
		JB	SF,ERROR						
		ACALL	DATAWRT								
		ANL	A,#0FH							
		MOV	D1,A							
		
	IP2:	ACALL 	KEYPAD								
		ACALL 	INPUT_CHECK							
		JB	DF,IP3							
		JB	SF,IP6							
		JB	EF,ERROR						
											
	IP3:	ACALL	DATAWRT								
		ANL	A,#0FH							
		MOV	TEMP,A													
		MOV	A,D1							
		MOV	B,#10												
		MUL	AB							
		ADD 	A,TEMP							
		MOV	D1,A							
		AJMP	IP10
		
	IP4:	MOV	TEMP,A						
		MOV	A, SIGN							
		CJNE	A,#0, ERROR
									
	IP5:	MOV	A,TEMP
							
	IP6:	ACALL	DATAWRT								
		MOV	SIGN,A						
		
	IP10:	ACALL 	KEYPAD							
		ACALL 	INPUT_CHECK							
		JB	SF,IP4							
		JB	EF,ERROR
								
	IP7:	ACALL	DATAWRT								
		ANL	A,#0FH							
		MOV	D2,A							
		ACALL 	KEYPAD							
		ACALL 	INPUT_CHECK							
		JB	DF,IP8							
		JB	SF,ERROR						
		JB	EF,IP9							
	IP8:	ACALL	DATAWRT								
		ANL	A,#0FH							
		MOV	TEMP,A							
		MOV	A,D2							
		MOV	B,#10							
		MUL	AB						
		ADD 	A,TEMP								
		MOV	D2,A							
		ACALL 	KEYPAD							
		ACALL 	INPUT_CHECK					
		JB	DF,ERROR					
		JB	SF,ERROR
							
	IP9:	ACALL	DATAWRT							
		AJMP	NOERROR	
								
ERROR:		ACALL	ERRORMAIN							
		LJMP	DONE							

NOERROR:	RET	



CALCULATION: 

		MOV		A,D1								
		MOV		B,D2								
		MOV		R0,SIGN								
		
		CJNE		R0, #"+", NEXT11
		ADD		A,B								
		MOV		R,A								
		MOV		RSIGN,#"+"							
		RET										
		
NEXT11:		CJNE		R0,#"-",NEXT22							
		SUBB		A,B								
		JC		NEG								
		MOV		R,A								
		MOV		RSIGN,#"+"							
		RET										
NEG:		CPL		A								
		INC 		A								
		MOV		R,A								
		MOV		RSIGN,#"-"							
		RET										
		
NEXT22:		CJNE		R0,#"*",NEXT33							
		MUL		AB								
		MOV		R,A								
		MOV		HB,B								
		MOV		RSIGN,#"+"							
		RET										
		
NEXT33:		CJNE		R0,#"/",ERROR							
		MOV		A,D2								
		JZ		ERROR								
		MOV		A,D1								
		MOV		TEMP,B								
OK: 		DIV		AB								
		MOV		R,A								
		MOV		A,#10								
		MUL		AB								
		MOV		B,TEMP								
		DIV		AB								
		MOV		FB,A								
		MOV		SIGN,#"+"


OUTPUT:
		MOV 	R1,#00D							  
        	MOV 	R2,#00D							
        	MOV 	R3,#00D							
        	MOV 	R4,#00D							 
			
		MOV	A,RSIGN							
		CJNE	A,#"-",NOSIGN											
		ACALL	DATAWRT							
		ACALL 	DELAY
		

NOSIGN:		MOV 	A,R							
		MOV 	B,#10D
        	DIV 	AB							
        	MOV 	R1,B							
        	MOV 	B,#10D							 
        	DIV 	AB							
        	MOV 	R2,B							
        	MOV 	R3,A							
		
		MOV	A,HB							
        	CJNE 	A,#00,NEXT						
       		LJMP	PRINT 							
		
NEXT:		MOV 	A,#6							
        	ADD 	A,R1							
        	MOV 	B,#10
        	DIV 	AB
        	MOV 	R1,B							
		
        	ADD 	A,#5
        	ADD 	A,R2
        	MOV 	B,#10
        	DIV 	AB
        	MOV 	R2,B							
		
        	ADD 	A,#2
        	ADD 	A,R3
        	MOV 	B,#10
        	DIV 	AB
        	MOV 	R3,B							
		
		ADD 	A,R4
        	MOV 	R4,A							
		DJNZ 	HB,NEXT							
		
PRINT:
		
		MOV 	A,R4							
		JNZ	PRINT1
		CLR 	ZF
		AJMP	L1
PRINT1: 	ADD	A,#30H							
        	ACALL	DATAWRT							
		SETB	ZF
        
	L1:	MOV 	A,R3							
		JNZ	PRINT2
		JNB	ZF,L2
PRINT2:		ADD	A,#30H							
        	ACALL	DATAWRT							
		SETB 	ZF
        
	L2: 	MOV 	A,R2							
		JNZ	PRINT3
		JNB	ZF,L3
PRINT3: 	ADD	A,#30H							
        	ACALL	DATAWRT							
		SETB 	ZF
        
    	L3: 	MOV 	A,R1							
		JNZ	PRINT4
PRINT4: 	ADD	A,#30H							
        	ACALL	DATAWRT							
		
		MOV	A,FB								
		CJNE	A,#0,POINTED					
		AJMP 	DONE							
		;
POINTED:	MOV	A,#"."							 
		ACALL	DATAWRT							
		MOV	A,FB								
		ADD	A,#30H							
		ACALL	DATAWRT							
		;
DONE:		LCALL KEYPAD 
		CJNE A, #99H, FW
	FW:	LJMP MAIN							
       		RET
	
KEYPAD:
	MOV A,#0FH
	MOV P2,A
K1: 	MOV P2,#00001111B
	MOV A,P2
	ANL A,#00001111B
	CJNE A,#00001111B,K1
K2: 	ACALL DELAY
	MOV A,P2
	ANL A,#00001111B
	CJNE A,#00001111B,OVER
	SJMP K2
OVER: 	ACALL DELAY
	MOV A,P2
	ANL A,#00001111B
	CJNE A,#00001111B,OVER1
	SJMP K2
OVER1: 	MOV P2,#11101111B ;A
	MOV A,P2
	ANL A,#00001111B
	CJNE A,#00001111B,ROW_0
	MOV P2,#11011111B ;B
	MOV A,P2
	ANL A,#00001111B
	CJNE A,#00001111B,ROW_1
	MOV P2,#10111111B ;C
	MOV A,P2
	ANL A,#00001111B
	CJNE A,#00001111B,ROW_2
	MOV P2,#01111111B ;D
	MOV A,P2
	ANL A,#00001111B
	CJNE A,#00001111B,ROW_3
	LJMP K2
ROW_0: 	MOV DPTR,#KCODE0
	SJMP FIND
ROW_1: 	MOV DPTR,#KCODE1
	SJMP FIND
ROW_2: 	MOV DPTR,#KCODE2
	SJMP FIND
ROW_3: 	MOV DPTR,#KCODE3

FIND: 	RRC A
	JNC MATCH
	INC DPTR
	SJMP FIND
MATCH:	CLR A
	MOVC A,@A+DPTR
	CJNE A, #99H, ON_AC
	MOV A,#01
	ACALL COMNWRT
	ACALL DELAY
	LJMP MAIN
ON_AC:
	RET 


COMNWRT:
	LCALL READY
	MOV P1,A
	CLR RS
	CLR RW
	SETB E
	ACALL DELAY
	CLR E
	RET
DATAWRT:
	LCALL READY
	MOV P1,A
	SETB RS
	CLR RW
	SETB E
	ACALL DELAY
	CLR E
	RET
READY: 	SETB P1.7
	CLR RS
	SETB RW
WAIT: 	CLR E
	LCALL DELAY
	SETB E
	JB P1.7,WAIT
	RET
	

INPUT_CHECK:	
								
			CJNE	A,#"+", FW1					
			AJMP	FOUND						
	FW1:		CJNE	A,#"-", FW2					
			AJMP	FOUND					
	FW2:		CJNE	A,#"*", FW3					
			AJMP	FOUND						
	FW3:		CJNE 	A,#"/", FW4					
			AJMP	FOUND						
	FW4:		CJNE	A,#"=", FW5					
			CLR		DF							
			CLR		SF							 
			SETB		EF								
			RET										
	FW5:		SETB		DF								
			CLR		SF								
			CLR		EF								
			RET										
	FOUND:		CLR		DF								
			SETB		SF								
			CLR		EF								
			RET										

ERRORMAIN: 	MOV A,#01H
		ACALL COMNWRT
		ACALL DELAY
		
		MOV DPTR, #EMSG
	
	E1: 	CLR A
		MOVC A,@A+DPTR
		ACALL DATAWRT
		ACALL DELAY
		INC DPTR
		JZ E2
		SJMP E1
	E2:	ACALL DELAY
	
		RET



DELAY: 	
	MOV R3,#50
HERE2: 	MOV R4,#255
HERE: 	DJNZ R4,HERE
DJNZ 	R3,HERE2
	RET



;ASCII LOOK-UP TABLE FOR EACH ROW
KCODE0: DB '/','9','8','7' ;ROW 0
KCODE1: DB '*','6','5','4' ;ROW 1
KCODE2: DB '-','3','2','1' ;ROW 2
KCODE3: DB '+','=','0',99H ;ROW 3
EMSG: 	DB "ERROR!",0
	END