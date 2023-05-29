           AREA RESET, DATA, READONLY
        EXPORT __Vectors
__Vectors
        DCD 0x20001000
        DCD Reset_Handler ; reset vector
        ALIGN
        AREA CS2400_Sp23, CODE, READONLY
        ENTRY
        EXPORT Reset_Handler
Reset_Handler
;------------------CODE HERE--------------------
;William Hellems-Moody , (Time Taken: 72 hours)
; Calculate the position of element in array using base_address + [i *#elements_per_row + j] * element_size

MAIN  

		LDR sp,=0x20000010 ; Load the base address of 0x20000010.
		MOV R1,#4 ; Move the value of N for the number or rows and columns.
		MUL R0,R1,R1; Obtain the value of N^2 using N.
		ADD R0,R0,#1 ; N^2 + 1 => 16 + 1 => 17.
		MUL R0,R0,R1 ; N(N^2 + 1) => 4(17) = 68.
		MOV R0,R0,LSR #1 ; N(N^2 + 1)/2 = 64/2 = 34 (our magic number) for each row, column and diagonal.
		
		MUL R11,R1,R1 ; Total elements in magic square N x N, which is N^2 elements.

		; Initialize variables
		LDR R2,=matrix ; load address of matrix.
		MOV R3,#0 ; int i = 0
		MOV R4,#0 ; int j = 0
		MOV R7,#0 ; Used to calculate sum for both rows and cols.
		MOV R9,#0 ; Counter for all loop(s).
		BL MAGIC_FUNCTION ; Branch to Magic function
		
		ADD R12,R12,#0 ; NOP Instruction
		ADD R12,R12,#0 ; NOP Instruction

		B stop
		
MAGIC_FUNCTION

		PUSH{LR} ; Push the link register to the stack pointer as a return address
		
ROW_LOOP
	
		MUL R5,R3,R1 ; i * N
		ADD R5,R5,R4 ; (i * N + j)
		MUL R5,R5,R1 ; (i * N + j) * N
		LDR R6,[R2,R5] ; Load Position of the element in array.
		
		ADD R7,R7,R6 ; Find the sum of each element in row.
		ADD R4,R4,#1 ; ; Get next element in array position for current row.
		ADD R9,R9,#1 ; Increment the counter for N elements in current row.	
		
		CMP R4,R1 ; Check if we have processed all N rows in the magic square. 
		BNE ROW_LOOP ; If values are not equal then loop again and compare after incrementing the counter.
		CMP R7,R0 ; Check if row sum (R7) is equal to magic number 0x22 or #34.
		BEQ NEXT_ROW ; If sum of row is equal to R0 then call function NEXT_ROW.
		BNE NOT_MAGIC_SQUARE ; If row sum is not equal to magic number then N x N is NOT a magic square.
		
NEXT_ROW

		ADD R3,R3,#1 ; Move to the next row to check next set of N elements.
		MOV R4,#0 ; Reset index for column j.
		MOV R7,#0 ; Reset sum to calculate sum of next row in magic sqaure. 
		CMP R9,R11 ; Counter size of magic square and determine if all elements have been counted for N^2.
		MOVEQ R3,#0 ; Reset int i = 0 if all elements are counted.
		MOVEQ R9,#0 ; Reset counter for row check.
		BEQ COL_LOOP ; If the all elements are counted then end the row loop and reset fields.
		b ROW_LOOP ; Rest and take the sum of next row.
		
COL_LOOP

		MUL R5,R3,R1 ; i * N
		ADD R5,R5,R4 ; (i * N + j)
		MUL R5,R5,R1 ; (i * N + j) * N
		LDR R6,[R2,R5] ; Load Position of the element in array.
		
		ADD R7,R7,R6 ; Find the sum of each element in column.
		ADD R3,R3,#1 ; Get next element in array position for current column.
		ADD R9,R9,#1 ; Increment counter for N elements in current column.
		
		CMP R3,R1 ; Check if we have processed all N columns in the magic square. 
		BNE COL_LOOP ; If values are not equal then loop again and compare after incrementing the counter.
		CMP R7,R0 ; Check if column sum (R7) is equal to magic number 0x22 or #34.
		BEQ NEXT_COL ; If sum of column is equal to R0 then call function NEXT_COL.
		BNE NOT_MAGIC_SQUARE ; If column sum is not equal to magic number then N x N is NOT a magic square.
		
NEXT_COL

		ADD R4,R4,#1 ; Move to the next column to check next set of N elements.
		MOV R3,#0 ; Reset index for row i.
		MOV R7,#0 ; Reset sum to calculate sum of next column in magic sqaure or first diagonal if all items counted. 
		CMP R9,R11 ; Counter size of magic square and determine if all elements have been counted for N^2.
		MOVEQ R4,#0 ; Reset int j = 0 if all elements are counted.
		MOVEQ R9,#0 ; Reset counter for column check.
		BEQ DIAG_LOOP1
		b COL_LOOP
		
DIAG_LOOP1

		MUL R5,R3,R1 ; i * N
		ADD R5,R5,R4 ; (i * N + j)
		MUL R5,R5,R1 ; (i * N + j) * N
		LDR R6,[R2,R5] ; Position of the element in array.
		
		ADD R7,R7,R6 ; Find the sum of each column.
		ADD R3,R3,#1 ; Get next element in array based on value of i. 
		ADD R4,R4,#1 ; Get next element in array based on value of j.
		ADD R9,R9,#1 ; Increment element counter.
		CMP R9,R1 ; Compare if counter is equal to the value of N elements.
		BNE DIAG_LOOP1 ; Loop again if not equal to total elements in diagnoal for N x N matrix.
		CMP R7,R0 ; Compare if equal to magic number if N elements have been counted.
		BNE NOT_MAGIC_SQUARE ; If sum of all diagonal elements are not equal to magic number then NOT magic square.

		; Reset values for index i, j, sum and counter for next diagonal check
		MOV R3,#0 ; int i = 0
		SUB R4,R4,#1 ; int j = 3
		MOV R7,#0 ; Reset sum to calculate sum second diagonal.
		MOV R9,#0 ; Counter

DIAG_LOOP2

		MUL R5,R3,R1 ; i * N
		ADD R5,R5,R4 ; (i * N + j)
		MUL R5,R5,R1 ; (i * N + j) * N
		LDR R6,[R2,R5] ; Position of the element in array
		
		ADD R7,R7,R6 ; Find the sum of each column.
		ADD R3,R3,#1 ; Get next element in array based on value of i.
		SUB R4,R4,#1 ; Get next element in array based on value of j.
		ADD R9,R9,#1 ; Increment element counter.
		CMP R9,R1 ; Compare if counter is equal to the value of N elements.
		BNE DIAG_LOOP2 ; Loop again if not equal to total elements in diagnoal for N x N matrix.
		CMP R7,R0 ; Compare if equal to magic number if N elements have been counted.
		BNE NOT_MAGIC_SQUARE ; If sum of all diagonal elements are not equal to magic number then NOT magic square.
		BEQ IS_MAGIC_SQUARE ; If sum of all diagonal, row, and column elements are equal R0 (0x22 or #34) then this matrix is a magic square.

IS_MAGIC_SQUARE

		MOV R8,#1 ; If matrix IS a magic square then update R8 and change to 1.
		B END_MAGIC_FUNCTION  ; Not magic square then branch out to END_MAGIC_FUNCTION

NOT_MAGIC_SQUARE

		MOV R8,#0 ; If matrix is NOT a magic square then update R8 and change to 0.
		B END_MAGIC_FUNCTION ; Not magic square then branch out to END_MAGIC_FUNCTION

END_MAGIC_FUNCTION

		POP{LR} ; Pop the link register from the stack pointer and return to the main function


;------------------CODE HERE--------------------
stop B stop
; Test value of magic sqaure provided is #34 or 0x22.
matrix DCD 16,3,2,13
  DCD 5,10,11,8
  DCD 9,6,7,12
  DCD 4,15,14,1
	  
	AREA myData,DATA,READWRITE
        END