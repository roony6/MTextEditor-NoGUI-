INCLUDE Irvine32.inc
INCLUDE macros.inc

BUFFER_SIZE = 2000

;---Prototype Proc------
WriteCreateFile proto, FileN: ptr byte, StringSize: Dword, Text: ptr byte
MyReadFromFile Proto, FileNa: ptr byte, Txt: ptr byte
Append proto, FileN:ptr byte, txt: ptr byte, sz: dword
Searchpr proto, intendedword: ptr byte, Text: ptr byte, choicebool: dword

.DATA
	;---ForAll----
		choice byte ?
		sChoice byte "(Choose). 1: CreateFile(Write), 2: ReadFile, 3: AppendToFile, 4: Search, 0: Exit", 0dh, 0ah, 0
		SFile byte "File Name : ", 0
		filename byte 20 dup(?), 0
		fileHandle HANDLE ?
		stringLength DWORD ?
		filesize	 DWORD ?
		Done byte "Done.", 0
		cont byte "Wanna Anything else(any num)-> 0: To Exit", 0dh, 0ah, 0
		sCh byte "Choice : ", 0
		Bye byte "Bye...:D..!", 0

		MyText byte BUFFER_SIZE dup(?), 0
		siz dword ?

	;----WriteInFile--		
		buffer byte BUFFER_SIZE DUP(?)
		wText byte "Write (Text) : ",0dh,0ah,0
		erWri byte "Cannot create file",0dh,0ah,0

	;----ReadFromFile--
		FileC byte "File Content: ",0dh,0ah,0
		erRead byte "Error reading file. ",0dh,0ah,0
		ColorsChoice		byte "Enter the color you want to display text with it",0dh,0ah,0
		Colors				byte "(Choose). 1: Blue, 2: Green, 3: Cyan, 4:Red, 5:Magenta",0dh,0ah,0
		readingcont			byte "Wanna 40 other chars? (any num)-> 0: To Exit", 0dh, 0ah, 0	
		colorChoice			dword ?
		iterations			dword ?

		
	;--Append--
		erApp byte "Cannot Find the File",0dh,0ah,0
		NewLine byte "You want to append in a new Line? 1:Yes: ", 0
		wApp byte "Text :",0
		choiceApp byte ?

	
	;--Search-- 
		size1 dword ?						    ; size of first string
		size2 dword ?							; size of first string
		lines dword 1000 dup(?)					;array to save lines of answers
		positions dword 1000 dup(?)				;array to save positions of answers
		linenumber dword ?                      ; to determine current line
		pos dword ?								; to determine current index of specific line
		ch1 byte ?								; get char from first string
		ch2 byte ?								; get char from first string
		cnt dword ?								; count how many chars in str1&str2 are equal
		indx dword ?
		ans dword ?								; number of solutions to determine number of iteration in arrays lines&position
		
		SearchChoiceMsg	byte "(Choose). 1: match case, 2: match whole word",0dh,0ah,0	
		WordMsg			byte "Enter the word you want to search for:",0dh,0ah,0	
		OccurrencesMsg  byte "Number of Occurrences = ",0
		Searchingword	byte 20 dup(?),0
		SearchChoice	dword ?
		NumberofOccurrences dword ?
		WordLength			dword ?
		FileLinesCounter    DWORD ?	
		CurrentLine         BYTE 250 DUP(?)
		
.code
main PROC



	NewC:
	mov edx, offset sChoice
	call writestring
	mov edx, offset sCh
	call writestring
	call readdec
	mov choice, al

	cmp choice, 0
	je quit
	cmp choice, 1
	je Write
	cmp choice, 2
	je Read
	cmp choice, 3
	je AppendTo
	cmp choice, 4 
	je Search




	jmp quit

	Write:
	;---UserWrite(CreateFile)-------------------------
	;-------------------------------------------------

	;--Taking The FileName--
		mov edx, offset sFile
		call writestring
		mov edx, offset filename
		mov ecx, 21
		call readstring

		mov edx, offset wText
		call writestring
		mov edx, offset MyText
		mov ecx, BUFFER_SIZE
		call readstring

	Invoke WriteCreateFile, offset filename, eax, offset MyText

		call crlf
		mov edx, offset cont
		call writestring
		mov edx, offset sCh
		call writestring
		call readdec
		cmp al, 0
		je quit
	jmp newC
	;-------------------------------------------------

	Read:
	;---ReadFromFile----------------------------------
	;-------------------------------------------------
	
	;--Taking The FileName--
		mov edx, offset sFile
		call writestring
		mov edx, offset filename
		mov ecx, 21
		call readstring

	Invoke MyReadFromFile, offset filename, offset MyText

		

		mov edx, offset ColorsChoice
		call writestring
		mov edx, offset Colors
		call writestring
		call readint
		mov colorChoice, eax
		mov edx, offset FileC
		call writestring
		MOV iterations, 0

		mov eax, colorChoice
		call    SetTextColor
		mov edx, offset MyText
		mov edi, offset MyText
		mov ecx, 40
		DisplayChars:
				inc iterations
				MOV al,[EDI]
				call writechar
				INC EDI		
		loop DisplayChars
		mov eax, iterations
		CMP eax, filesize
		JAE ChoicesMsg

		mov al, 0ah
		call writechar
		mov eax,15
		call    SetTextColor
		MOV EDX, OFFSET readingcont
		call writestring 
		mov eax, colorChoice
		call    SetTextColor
		mov ecx, 10
		call readint 
		cmp eax, 0
		jne DisplayChars

		
	ChoicesMsg:
		mov eax, 15
		call    SetTextColor
		call crlf
		mov edx, offset cont
		call writestring
		mov edx, offset sCh
		call writestring
		call readdec
		cmp al, 0
		je quit
	jmp newC
	;-------------------------------------------------

	AppendTo:
	;---UserAppend------------------------------------
	;-------------------------------------------------
	mov eax, 3
	call writedec
	call crlf

	;--Taking The FileName
		mov edx, offset sFile
		call writestring
		mov edx, offset filename
		mov ecx, 21
		call readstring

		mov edx, offset NewLine
		call writestring
	
		mov edx, offset sCh
		call writestring
		call readdec
		mov choiceApp , al
		mov edx, offset wApp
		call writestring
		cmp choiceApp, 1
		jne sameLine
	
		mov edx, offset MyText
		mov byte ptr [edx], 0dh
		inc edx
		mov byte ptr [edx], 0ah

		mov edx, offset MyText+2
		mov ecx, BUFFER_SIZE
		call readstring
		mov siz, eax
		add siz, 2

	Invoke Append, offset filename ,offset MyText, siz

	jmp newC

	sameLine:
		mov edx, offset MyText
		mov ecx, BUFFER_SIZE
		call readstring
		mov siz, eax

	Invoke Append, offset filename ,offset MyText, siz


	call crlf
	mov edx, offset cont
	call writestring
	mov edx, offset sCh
	call writestring
	call readdec
	cmp al, 0
	je quit
	jmp newC
	;-------------------------------------------------
	
	Search:
	;---Search----------------------------------------
	;----MatchCase Sensitive/not Sensitive------------
	;-------------------------------------------------
	mov edx, offset sFile
		call writestring
		mov edx, offset filename
		mov ecx, 21
		call readstring

	Invoke MyReadFromFile, offset filename, offset MyText

	mov edx, offset SearchChoiceMsg
	call writestring

	call readint
	mov SearchChoice, eax
	
	mov edx, offset WordMsg
	call writestring

	mov edx, offset Searchingword	
	mov ecx, 20
	call readstring
	mov WordLength, eax

	;Invoke Searchpr, offset Searchingword , offset MyText, SearchChoice

	;


	mov linenumber , 1                 
	mov cnt , 0
	mov pos , 1
	mov ans , 0

	cmp SearchChoice,1
	je MatchCase
	cmp SearchChoice,2
	je WholeWord
;	mov NumberofOccurrences,0
	MatchCase:
			INVOKE Str_ucase, ADDR MyText
			INVOKE Str_ucase, ADDR Searchingword
				mov size2 , eax
	mov esi , offset MyText
	mov edx , offset lines
	mov ebx , offset positions
	mov ecx , lengthof MyText
	sub ecx , size2
	inc ecx
	L1:
		push ecx
		mov ecx, size2
		mov al , [esi]
		cmp al , 0dh
		je elselp
		mov edi, offset Searchingword
		mov cnt, 0
		mov eax, esi
		L2:
			push eax
			mov al , [edi]
			mov ch1 , al
			pop eax
			push edx
			mov dl , [eax]
			cmp ch1 , dl
			pop edx
			jne else1
			inc cnt
			else1:
			inc eax
			inc edi
		loop L2 
			mov eax , size2
			cmp cnt , eax
			jne endd
			push eax
			mov eax, linenumber
			mov [edx], eax
			mov eax, pos
			mov [ebx], eax
			pop eax
			inc ans
			add edx ,4
			add ebx ,4
			jmp endd
		elselp:
		inc linenumber 
		mov pos, -1
	endd:
	inc pos
	inc esi
	pop ecx
	dec ecx
	jnz L1

cmp ans , 0
je exitt
mov eax, ans
call writedec
call crlf
mov ecx , ans
mov esi , offset positions 
mov edi , offset lines 
l3:
	mWrite<"Founded at position: ">
	mov eax , [esi]
	call writedec
	mov al , ' '
	call writechar
	mWrite<",Line : ">
	mov eax , [edi]
	call writedec
	call crlf
	add esi ,4
	add edi , 4
loop l3

call crlf
	jmp nnext
	WholeWord:
	mov size2 , eax
	mov esi , offset MyText
	mov edx , offset lines
	mov ebx , offset positions
	mov ecx , lengthof MyText
	sub ecx , size2
	inc ecx
	L4:
		push ecx
		mov ecx, size2
		mov al , [esi]
		cmp al , 0dh
		je elselp2
		mov edi, offset Searchingword
		mov cnt, 0
		mov eax, esi
		L5:
			push eax
			mov al , [edi]
			mov ch1 , al
			pop eax
			push edx
			mov dl , [eax]
			cmp ch1 , dl
			pop edx
			jne else4
			inc cnt
			else4:
			inc eax
			inc edi
		loop L5 
			mov eax , size2
			cmp cnt , eax
			jne endd2
			push eax
			mov eax, linenumber
			mov [edx], eax
			mov eax, pos
			mov [ebx], eax
			pop eax
			inc ans
			add edx ,4
			add ebx ,4
			jmp endd2
		elselp2:
		inc linenumber 
		mov pos, -1
	endd2:
	inc pos
	inc esi
	pop ecx
	dec ecx
	jnz L4

cmp ans, 0
je exitt
mov eax, ans
call writedec
call crlf
mov ecx , ans
mov esi , offset positions 
mov edi , offset lines 
l6:
	mWrite<"Founded at position: ">
	mov eax , [esi]
	call writedec
	mov al , ' '
	call writechar
	mWrite<",Line : ">
	mov eax , [edi]
	call writedec
	call crlf
	add esi ,4
	add edi , 4
loop l6

call crlf
jmp nnext
	exitt:
	mWrite<"Not Found",0dh,0ah>
	nnext:
	;
	call crlf
	mov edx, offset cont
	call writestring
	mov edx, offset sCh
	call writestring
	call readdec
	cmp al, 0
	je quit
	jmp newC
	;-------------------------------------------------

	ChangeColor:
	;---ChangeColor----------------------------------------
	;------Color Of Text-----------------------------------

	call crlf
	mov edx, offset cont
	call writestring
	mov edx, offset sCh
	call writestring
	call readdec
	cmp al, 0
	je quit
	jmp newC
	;-------------------------------------------------

	call crlf
	quit:
	call crlf
	mov edx, offset Bye
	call writestring
	call crlf

exit
main ENDP

;---------------------------------------
;---Create New File(Save As)------------
;--receives File Name, Text, Size of Text, Text--
;---------------------------------------
WriteCreateFile Proc, FileN: ptr byte, StringSize: Dword, Text: ptr byte

; Create a new text file.
	mov edx, FileN
	call CreateOutputFile
	mov fileHandle, eax

; Check for errors.
	cmp eax, INVALID_HANDLE_VALUE ; error found?
	jne file_ok			; no: skip
	mov edx,OFFSET erWri ; display error
	call WriteString
	jmp quit

file_ok:
; Write the buffer to the output file.
	mov eax, fileHandle
	mov edx, Text
	mov ecx, StringSize
	call WriteToFile
	mov StringSize, eax ; save return value
	call CloseFile
	mov edx, offset Done
	call writestring
	call crlf

quit:
	call crlf
	ret
WriteCreateFile Endp





;---------------------------------------
;----Read From Specific File------------
;----File Name, Text--------------------
;---------------------------------------
MyReadFromFile Proc, FileNa: ptr byte, Txt: ptr byte

; Open the file for input.
	mov	edx, FileNa
	call OpenInputFile
	mov	fileHandle,eax

; Check for errors.
	cmp	eax, INVALID_HANDLE_VALUE		; error opening file!!?
	jne	file_ok							; no: skip
	mov edx, offset erApp
	call writestring
	jmp	quit	;quit
							
file_ok:
; Read the file into a buffer.
	mov	edx, Txt
	mov	ecx, BUFFER_SIZE
	call ReadFromFile
	jnc	check_buffer_size			; error reading?
	mov edx, offset erRead		; yes: show error message
	call writestring
	jmp	close_file
	
check_buffer_size:
	cmp	eax, BUFFER_SIZE			; buffer large enough?
	jb	buf_size_ok				; yes
	mWrite <"Error: Buffer too small for the file",0dh,0ah>
	jmp	quit						; and quit
	
buf_size_ok:
	mov	txt[eax],0		;null terminator
	mov filesize, eax
	mov edx, offset Done
	call writestring
	call crlf
close_file:
	mov	eax,fileHandle
	call	CloseFile

quit:
	call crlf
	ret
MyReadFromFile ENDP


;---------------------------------------
;----Append In Specific File------------
;----File Name, Text, Size of Text------
;---------------------------------------
Append proc, FileN:ptr byte, txt: ptr byte, sz: dword

	INVOKE CreateFile,
				fileN, GENERIC_WRITE, DO_NOT_SHARE, NULL,
					OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0

	mov fileHandle,eax			; save file handle
	cmp	eax, INVALID_HANDLE_VALUE
	jne OK
	  mov  edx,OFFSET erApp		; Display error message
	  call WriteString
	  jmp  quit

OK:
	; Move the file pointer to the end of the file
	INVOKE SetFilePointer,
				fileHandle,0,0,FILE_END

	; Append text to the file
	INVOKE WriteFile,
				fileHandle, txt, sz,
					ADDR stringLength, 0

	INVOKE CloseHandle, fileHandle
	mov edx, offset Done
	call writestring
	call crlf

quit:
	call crlf
	ret
Append EndP
comment &
;---------------------------------------
;----Search In Specific File------------
;----whole word, match case------
;----receives searching word, whole text, searching type
;---------------------------------------
Searchpr proc, intendedword: ptr byte, Text: ptr byte, choicebool: dword
	
	cmp choicebool,1
	je MatchCase
	cmp choicebool,2
	je WholeWord
	mov NumberofOccurrences,0
	MatchCase:
			INVOKE Str_ucase, ADDR MyText
			INVOKE Str_ucase, ADDR Searchingword
			mov ecx, filesize
			mov edi, offset MyText
			MatchCaseOuterLoop:
				mov al,[edi]
				mov esi, offset Searchingword
				cmp [esi], al
				jne MatchCaseOuterLoopNewItert
				mov ebx, ecx
				mov edx, edi
				mov ecx, WordLength
				MatchCaseInnerLoop:
								mov al,[edx]
								cmp al, [esi]
								jne MatchCaseOuterLoopNewItert
								inc edx
								inc esi
				loop MatchCaseInnerLoop
				mov ecx, ebx
				inc NumberofOccurrences
			MatchCaseOuterLoopNewItert:
										inc edi
			loop MatchCaseOuterLoop
			
			jmp quit
	WholeWord:
			mov NumberofOccurrences,0
			mov ecx, filesize
			mov edi, Text
			WholeWordOuterLoop:
				mov al,[edi]
				mov esi, intendedword
				cmp [esi], al
				jne WholeWordOuterLoopNewItert
				mov ebx, ecx
				mov edx, edi
				mov ecx, WordLength
				WholeWordInnerLoop:
								mov al,[edx]
								cmp al, [esi]
								jne WholeWordOuterLoopNewItert
								inc edx
								inc esi
				loop WholeWordInnerLoop
				mov ecx, ebx
				inc NumberofOccurrences
			WholeWordOuterLoopNewItert:
										inc edi
			loop WholeWordOuterLoop
quit:
	mov edx,offset OccurrencesMsg
	call WriteString 
	mov eax, NumberofOccurrences
	call writedec
	call crlf
	ret
Searchpr EndP
&

;---------------------------------------
;----Search In Specific File------------
;----whole word, match case------
;----receives searching word, whole text, searching type
;---------------------------------------
;Searchpr proc, intendedword: ptr byte, Text: ptr byte, choicebool: dword
	
;	ret
;Searchpr EndP

END main

