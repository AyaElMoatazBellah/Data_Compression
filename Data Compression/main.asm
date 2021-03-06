INCLUDE Irvine32.inc
INCLUDE macros.inc

BUFFER_SIZE = 5000   ;number of bytes will be read from the file , must be greater than file bytes.
.DATA

node struct 
S byte ?
weight dword ?
left dword ?
right dword ?
copy_weight dword ?
code byte 10 dup(?)
code_size dword ?
node ends
counter dword 0
MIN dword ?
array_char_accurance byte 26 dup(?)
array_linear_tree dword 100 dup(?) ;change size
letter_index byte ? 
array node 100 dup(<?>)
min1 dword ?
min2 dword ?
index1 dword ?
index2 dword ?
index_holder dword ?
charHolder byte 'z'             ;to redirect read char to its correct index in the charsArr
charsArr byte 26 dup(0)        ;hold all EnglishChars Frequency and init by 0 
fileName byte 'FileInput.txt',0
actualFileSize dword ?
structCounter dword 0
charIndex dword 0
buffer BYTE BUFFER_SIZE DUP(?)
fileHandle handle ?
convertedTree node 100 dup(<?>)
code_array BYTE 100 dup (?)
lengArr BYTE ?
SavedCodeArr byte 100 dup(?)
lenCodeArr dword 0
;==============================
bufferOut byte BUFFER_SIZE dup(?)
fileOutName byte ?
stringOutlength dword ?
str1 byte "cannot create file ",0dh,0ah,0
str4 byte "Enter The File Name : ",0
mes5 byte "The New Chars Frequancy Are : ",0
mes6 byte "-----------------------------------------------------------------",0
mes7 byte "Enter the Name For Compressed Text File : ",0
mes8 byte "Enter the Name For New Huffman Tree File : ",0
mes9 byte "The Huffman Tree is : ",0
mes10 byte "Enter The Code To BE Decoded : ",0
mes11 byte "The Original Text Is : ",0
mes12 byte "Enter The Original Text File Name  : ",0
counterr dword 0 
array_copy byte BUFFER_SIZE DUP(?)
FH handle ?
;======================================
outputFileName byte  'm.txt',0 ; Output File Path  
outputFileHandle handle ?
outputBuffer BYTE BUFFER_SIZE DUP(?)
;======================
fileName2 byte 'mm.txt',0
outputfile2handel handle ?
filebuffer2 byte BUFFER_SIZE DUP(?)
;==================================
array_char_accurance2 byte 26 dup(?)
array_linear_tree2 dword 100 dup(?) ;change size

.code
find_min proc
	mov MIN, 99999999;
	mov esi, 0;
	mov edi, -1;
	loop_find:
		mov al,array[esi].S;
		cmp al,'$';
			je break_find;
			mov eax,array[esi].weight;
			cmp eax,-1;
				je cont;
				cmp eax,MIN;
					jnb NO_swap;
					mov MIN,eax;
					mov edi,esi;
				NO_swap:
	cont:
	add esi,sizeof node;
	jmp loop_find;
	break_find:
	
	mov ecx, edi
	Cmp ecx, -1	
		JE exitproc
		mov array[edi].weight,-1;
		mov eax,MIN;
	exitproc: 
	ret
find_min endp
;-----------------------------------------------------

huffman proc
	build:
	call find_min;
	cmp edi,-1
		je break_huffman;
		mov min1,eax;
		mov index1,edi;
		call find_min;
		cmp edi,-1
			je break_huffman;
			mov min2,eax;
			mov index2,edi;
		call insert_node;
	jmp build;
	break_huffman:
	
	ret
huffman endp
;-----------------------------------------------------
insert_node proc
	mov esi,0;
	LOOP1:
		mov al,array[esi].S;
		cmp al,'$'
			je LOOP1_break;
		add esi,sizeof node;
		loop LOOP1;
		LOOP1_break:
			
		mov array[esi].S,'#'
		mov eax,min1;
		add eax,min2;
		mov array[esi].weight,eax;
		mov array[esi].copy_weight,eax;
		mov eax,index1;
		mov array[esi].left,eax;
		mov eax,index2;
		mov array[esi].right,eax;
		add esi,sizeof node;
		mov array[esi].S,'$';
	ret
insert_node endp
;-----------------------------------------------------
display proc
	mov esi,0
	output:
		mov al,array[esi].S;
		cmp al,'$'
		call writechar
	je break_output;
	mov eax,array[esi].copy_weight;

call writedec;
call crlf;
add esi,sizeof node
jmp output;

break_output:
ret
display endp

;-----------------------------------------------------
getcode proc
	mov esi,0;
	loop_char:
		mov al,array[esi].S;
		cmp al,'#'
			je break_loopchar;
			mov al,array[esi].S;
			mov edi,0;
			mov ebx,esi;
			mov edx,0;
			loop_find_index:
				mov al,array[edi].S;
				cmp al,'$';
					je break_find_index;
					mov al,array[edi].S;
					cmp al,'#';
						jne contione;
						cmp ebx,array[edi].left;
							jne else_right;
							mov array[esi].code[edx],0;
							inc edx;
							mov ebx,edi;
						else_right:
						cmp ebx,array[edi].right;
							jne contione;
							mov array[esi].code[edx],1;
							inc edx;
							mov ebx,edi;
						contione:
			add edi,sizeof node;
			jmp loop_find_index;
			break_find_index:
		mov ecx,edx;
		mov al,array[esi].S;
		call writechar;
		mov al , ' '
		call writechar
		mov al , ':'
		call writechar
		mov array[esi].code_size,ecx;
		dec edx

display_stack:
movzx eax,array[esi].code[edx];
dec edx
call writedec;
loop display_stack;
add esi,sizeof node;
call crlf
	jmp loop_char;
	break_loopchar:
	ret
getcode endp
;-----------------------------------------------------
GetFileData PROC

;Open the file for input.
 mov edx , OFFSET fileName
 call OpenInputFile
 mov fileHandle,eax

; Check for errors.
 cmp eax , INVALID_HANDLE_VALUE     ; error opening file?
 jne file_ok                        ;no: skip
 mWrite <"Cannot open this file",0dh,0ah>
 jmp quit                           ;and quit

file_ok:
; Read the file into a buffer.
 mov edx , OFFSET buffer
 mov ecx , BUFFER_SIZE
 call ReadFromFile

jnc check_buffer_size ; error reading?
 mWrite "Error reading file. " ; yes: show error message
 call WriteWindowsMsg
 jmp close_file

check_buffer_size:
 cmp eax , BUFFER_SIZE   ; buffer large enough?
 jb buf_size_ok        ; yes
 mWrite <"Error: Buffer too small for the file",0dh,0ah>
 jmp quit              ; and quit

buf_size_ok:
 mov buffer[eax] , 0   ; insert null terminator ,, bec when read to terminate when find 0
 mov actualFileSize , eax    ;save actual fileSize; 

; Display the buffer.
 mWrite <"The Input File Is : "> 
 mov edx , OFFSET buffer     ;display the buffer , terminate when reach 0
 call WriteString
 call Crlf

close_file:
 mov eax , fileHandle
 call CloseFile
quit:
ret
GetFileData ENDP
;------------------------------------------------------

CountCharsFrequencies PROC

mov edi , offset charsArr
mov ecx , actualFileSize
mov ebx , 0

countCharsFrequency:
 mov edx , offset buffer
 mov eax , 0
 mov al , charHolder
 sub al , [edx + ebx]  ; get Index of this char in charsArray
 inc byte ptr[edi + eax]        ; inc frequenct of this char
 inc ebx 
Loop countCharsFrequency

ret
CountCharsFrequencies ENDP

;--------------------------------------------------------------------
InitNodes PROC

mov edi , offset charsArr
mov esi , 0
mov ecx , 26

initCharsStruct:    ; create struct to any char that its frequency not equal to 0

 movzx eax , byte ptr [edi]
 cmp eax , 0
 je cont

;init a new structNode

 mov ebx , 122
 sub ebx , charIndex    ;return it to the original char by adding z char ASCII
 mov array[esi].S , bl
 mov array[esi].weight , eax
 mov array[esi].left , -1
 mov array[esi].right , -1
 mov array[esi].copy_weight , eax

add esi , sizeof node 
inc structCounter

cont:
inc edi
inc charIndex
Loop initCharsStruct

mov array[esi].S,'$';

ret
InitNodes ENDP


DisplayNodes PROC

mov ecx , structCounter
mov esi , 0
DisplayNodesArr:


mov al , array[esi].s
call writechar
call crlf
mov eax , array[esi].weight
call writedec
call crlf
add esi , sizeof node 
call crlf
Loop DisplayNodesArr

ret
DisplayNodes ENDP
;-----------------------------------------------------
get_linear_tree proc
    
	call crlf
    mov edx ,offset mes9
	call writestring 
	call crlf 

	mov esi,0
	mov ecx,0
	get_num_char:
		mov al, array[esi].S
		cmp al, '$'
		je break_get_num_char
		inc ecx
		add esi, sizeof node
	jmp get_num_char
	break_get_num_char:
		;--- break from loop so we add root to the array
	sub esi, sizeof node
	mov eax, array[esi].copy_weight
	mov array_linear_tree, eax
	
	mov edi, 0
	mov edx, 4
	mov letter_index, 0
		;letter_index to add letter in array of letters
		;ecx 3dd l lfat 
		;edi index ely bmshy byha 3la kol element fl array_linear_tree 
		;esi index bmshy byh 3la l array of nodes
		;edx index to appened the next element
	
	fill_array_linear_tree:
		cmp ecx, 0 ;breaking condition
			je break_fill_array_linear_tree 
		
		mov eax, array_linear_tree[edi]
		mov esi, 0
		cmp eax, 0
			je continue_fill
			find_element: cmp eax, array[esi].copy_weight
				jne next_element 
				mov eax, array[esi].left ; index of left
				cmp eax, -1 
					je appened_zeros
				mov ebx, array[eax].copy_weight ; actual weight of left 
				mov array_linear_tree[edx], ebx
				
				add counterr , 1
				
				add edx, 4
				mov eax, array[esi].right ;index of right
				mov ebx, array [eax].copy_weight ;actual weight of right
				mov array_linear_tree[edx], ebx
				
				add counterr , 1

				add edx, 4
				dec ecx
				jmp continue_fill
			next_element: add esi, sizeof node
			jmp find_element
			appened_zeros:
				mov ebx, 0 
				mov array_linear_tree[edx], ebx
				
				add counterr , 1

				add edx, 4
				mov array_linear_tree[edx], ebx 
				
				add counterr , 1
				
				add edx, 4
				dec ecx
					;add letter in array of letters
				movzx eax, letter_index ;index
				mov bl, array[esi].S ;char
				mov array_char_accurance[eax], bl
				add letter_index,4
		continue_fill:
		add edi, 4

	jmp fill_array_linear_tree
	break_fill_array_linear_tree:
	cmp letter_index, 26
		je is_26
		movzx eax, letter_index
		mov array_char_accurance[eax], -1
	is_26:
	mov array_linear_tree[edx], -1
	mov edi, 0
	print_array:
		mov eax,array_linear_tree[edi]
		cmp eax, -1
			je break_print_array
			call writeDec
			mov al,' '
		    call writeChar
		add edi,4
	jmp print_array
	break_print_array:
	
	call crlf
	mov esi , offset array_char_accurance
	mov ecx , counterr
	lop:
	mov al , [esi]
	call writechar 
	inc esi 
	loop lop

	call crlf 
	call crlf 
	ret
get_linear_tree endp
;-----------------------------------------------------
decode PROC

    mov edx , offset mes10
	call writestring 
	call crlf

	mov edx, offset code_array
    mov ecx,100
	call readstring
	call crlf

    mov lengArr, al
	mov esi,0
	movzx ecx,lengArr
	mov ebp,0
	mov edi , offset SavedCodeArr
	
	mov edx , offset mes11
	call writestring 
	call crlf 

	displaycode:
		mov al,code_array[ebp]
		cmp al,'0'
			je left
		mov edx, convertedTree[esi].right
		mov al,convertedTree[edx].S
		cmp al,'#'
		jne endLOOP
		mov esi,edx
		;add esi,sizeof node		
		jmp break
		left:
			mov edx, convertedTree[esi].left
			mov al,convertedTree[edx].S
			cmp al,'#'
			jne endLOOP
			mov esi,edx
			;add esi,sizeof node
			jmp break
			
      endLOOP:
		mov esi ,0
		call writechar
		mov byte ptr [edi],al
		inc edi 
		inc lenCodeArr
		break:
	    inc ebp
	loop displaycode
	call crlf

	RET
decode ENDP
;-----------------------------------------------------

;-----------------------------------------------------
convert_tree PROC
;ecx,edi,esi,edx,eax
	 mov ecx ,22    ; changed size when reading file
	 mov edi,0
	 mov esi,0
	 mov eax,0
	 mov letter_index,0	
	 mov edx,array_linear_tree2[edi]
	 mov convertedTree[esi].weight,edx
	  convertLOOP:

		mov convertedTree[eax].S,'#'
		
		add esi,sizeof node
		add edi,4
		
		mov edx,array_linear_tree2[edi]
		
		cmp edx,0
			je leaf
		mov convertedTree[esi].weight,edx
		mov convertedTree[eax].left,esi

		add esi,sizeof node
		add edi,4
		dec ecx

		mov edx,array_linear_tree2[edi]
		mov convertedTree[esi].weight,edx
		mov convertedTree[eax].right,esi

		jmp endloop 

		leaf:
			sub esi,sizeof node  
			movzx ebp,letter_index			
			add letter_index,1			
			mov bl,array_char_accurance2[ebp]
			mov convertedTree[eax].S,bl
			mov convertedTree[eax].left,-1
			mov convertedTree[eax].right,-1
			add edi,4
			dec ecx
		
		endloop:
			add eax,sizeof node
		loop convertLOOP 

	RET
convert_tree ENDP
;-----------------------------------------------------
;-----------------------------------------------------
SaveHuffmanTree PROC

mov ebx,offset array_linear_tree
mov edx,offset array_copy
mov ecx, counterr
add ecx ,1

loop_copy:
movzx eax, byte ptr[ebx]
add al , 48 
mov byte ptr [edx],al
inc edx
add ebx,4
loop loop_copy

inc edx
mov byte ptr [edx] , ' '
movzx ecx ,letter_index
mov ebx ,offset array_char_accurance
inc edx 

l4:
movzx eax ,byte ptr[ebx]
mov byte ptr[edx] , al
inc ebx 
inc edx
loop l4

mov edx , offset mes8
call writestring 

mov ecx , 200
mov edx , offset fileOutName
call readstring
mov edx , offset fileOutName
call createoutputfile
mov FH,eax

cmp eax , INVALID_HANDLE_VALUE
jne file_ok
mov edx ,offset str1
call writestring 
jmp quit 

file_ok:
mov eax , FH

mov edx ,offset array_copy
mov ecx ,counterr
movzx esi ,letter_index
add ecx , esi
add ecx ,1
call writetofile

call closefile

quit:
ret
SaveHuffmanTree ENDP
;-------------------------------------------
SaveEncodingToFile PROC

mov edx , offset buffer
mov ecx , actualFileSize
mov ebx , 0
mov edi , 0

TraverseFileChars:
  mov al , [edx + ebx]   ; hold file char in al and search for its opposite code in array struct nodes
  mov esi , 0

FindCharIndex:
  cmp al , array[esi].S
  je getCharCode   ; when find this char it will break outside
  add esi , sizeof node
  jmp FindCharIndex

getCharCode:
  push ecx
  mov ecx , array[esi].code_size
  
FindCharCode:
  movzx eax , array[esi].code[ecx-1]   ; save it in reverse way
  add al , 48       ; bec file deal with it as a byte ==> save to output buffer to write it in the output file  
  mov byte ptr outputBuffer[edi] , al 
  inc edi
  Loop FindCharCode

 pop ecx
 inc ebx
Loop TraverseFileChars

; Create a new text file.

mov edx , offset mes7
call writestring 


mov edx , offset outputFileName
call CreateOutputFile
mov outputFileHandle , eax

; Check for errors.
  cmp eax, INVALID_HANDLE_VALUE ; error found?
  je check_quit

; Write Encode to the File Output
  mov eax , outputFileHandle
  mov edx , offset outputBuffer
  mov ecx , edi        ; edi hold all number of bytes of output buffer array
  call WriteToFile
  call CloseFile

check_quit:
ret
SaveEncodingToFile ENDP
;-------------------------------------------------

OpenFileDecode PROC

; Open the file for input.
  mov edx , OFFSET fileName2
  call OpenInputFile
  mov outputfile2handel,eax

; Check for errors.
  cmp eax , INVALID_HANDLE_VALUE     ; error opening file?
  jne file_ok                        ;no: skip
  mWrite <"Cannot open this file",0dh,0ah>
  jmp quit                           ;and quit

file_ok:

; Read the file into a buffer.
mov edx , OFFSET filebuffer2
mov ecx , BUFFER_SIZE
call ReadFromFile
call crlf

jnc check_buffer_size ; error reading?
mWrite "Error reading file. " ; yes: show error message
call WriteWindowsMsg
jmp close_file

check_buffer_size:
cmp eax , BUFFER_SIZE   ; buffer large enough?
jb buf_size_ok        ; yes
mWrite <"Error: Buffer too small for the file",0dh,0ah>
jmp quit              ; and quit

buf_size_ok:
mov filebuffer2[eax] , 0   ; insert null terminator ,, bec when read to terminate when find 0
mov actualFileSize , eax    ;save actual fileSize; 

mWrite <"The Opened File To Be Decoded Is : ">
call crlf
mov edx ,offset filebuffer2 
mov edi , offset array_linear_tree2
mov esi ,offset array_char_accurance2
mov ecx , actualFileSize
mov ebx , 0
lop1:
movzx eax ,byte ptr [edx]
cmp eax , ' '
je lop2
sub eax , 48
mov dword ptr [edi] , eax
add edi , 4 
inc edx 
loop lop1

lop2:
movzx eax ,byte ptr[edx]
cmp eax , ' '
je cont
mov byte ptr [esi] , al 
add esi , 1
inc ebx 
cont:
inc edx
loop lop2

; Display the buffer.
call crlf 
mov edx , OFFSET filebuffer2     ;display the buffer , terminate when reach 0
call WriteString
call Crlf
close_file:
mov eax , outputfile2handel
call CloseFile

quit:
ret
OpenFileDecode ENDP
;-------------------------------------
SaveOriginalText PROC

mov edx , offset mes12
call writestring 

mov ecx , 200
mov edx , offset fileOutName
call readstring
mov edx , offset fileOutName
call createoutputfile
mov FH,eax

cmp eax , INVALID_HANDLE_VALUE
jne file_ok
mov edx ,offset str1
call writestring 
jmp quit 

file_ok:
mov eax , FH
mov edx ,offset SavedCodeArr
mov ecx ,lenCodeArr
call writetofile
call closefile

quit:
ret
SaveOriginalText ENDP

Space PROC
call crlf
mov edx , offset mes6
call writestring
call crlf
ret
Space ENDP

main PROC

call Space 
call crlf
call GetFileData
call CountCharsFrequencies
call InitNodes
call huffman;

call Space
mov edx , offset mes5
call writestring
call crlf
call getcode;

call SaveEncodingToFile
call Space
call get_linear_tree
call SaveHuffmanTree
call Space

call OpenFileDecode
call convert_tree
call crlf
call decode
call crlf 
call SaveOriginalText
call Space

	exit
main ENDP
END main