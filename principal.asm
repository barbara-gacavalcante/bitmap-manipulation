.686
.model flat, stdcall
option casemap :none
 
include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc
include \masm32\include\user32.inc
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\masm32.lib

 
; ----------------- variaveis inicializadas ---------------
 
.data
    msg0 db "Digite o nome do arquivo de entrada:", 0ah, 0h
    msg1 db "Digite a coordenada X:", 0ah, 0h
    msg2 db "Digite a coordenada Y:", 0ah, 0h
    msg3 db "Digite a largura:", 0ah, 0h
    msg4 db "Digite a altura:", 0ah, 0h
    msg5 db "Digite o nome do arquivo de saida:", 0ah, 0h
 
    entrada db 5 dup(0)
    arqent db 40 dup(0)
    arqsaid db 40 dup(0)
    fileBuffer db 1024 dup(0)
    linhaBuffer db 6480 dup(0)
    newline db 0ah, 0h
    
    larg dd 4 dup(0)
    alt dd 4 dup(0)

    count dd 0
    count2 dd 0
    fInHandle dd 0
    fOutHandle dd 0
    inputHandle dd 0
    outputHandle dd 0
    contador dd 0 ; variavel caracteres escritos
      
; ----------------- variaveis declaradas -----------------
 
.data?
    linha DWORD ?
    iniCens DWORD ?
    fimCens DWORD ?
    valorx DWORD ?
    valory DWORD ?
    larguraCensura DWORD ?
    alturaCensura DWORD ?
 
; -------------------------= MAIN =--------------------------
 
.code

start:
 
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
 
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
     
    ; --------- arquivo de entrada
    
    invoke WriteConsole, outputHandle, addr msg0, sizeof msg0, addr contador, NULL
    invoke ReadConsole, inputHandle, addr arqent, sizeof arqent, addr contador, NULL
    push offset arqent
    call trataString
     
    ; --------- recebe entradas
    
    invoke WriteConsole, outputHandle, addr msg1, sizeof msg1, addr contador, NULL
    invoke ReadConsole, inputHandle, addr entrada, sizeof entrada, addr contador, NULL
    push offset entrada 
    call trataString
    invoke atodw, addr entrada
    mov valorx, eax
 
    invoke WriteConsole, outputHandle, addr msg2, sizeof msg2, addr contador, NULL
    invoke ReadConsole, inputHandle, addr entrada, sizeof entrada, addr contador, NULL
    push offset entrada 
    call trataString
    invoke atodw, addr entrada
    mov valory, eax
     
    invoke WriteConsole, outputHandle, addr msg3, sizeof msg3, addr contador, NULL
    invoke ReadConsole, inputHandle, addr entrada, sizeof entrada, addr contador, NULL
    push offset entrada 
    call trataString
    invoke atodw, addr entrada
    mov larguraCensura, eax
    
    invoke WriteConsole, outputHandle, addr msg4, sizeof msg4, addr contador, NULL
    invoke ReadConsole, inputHandle, addr entrada, sizeof entrada, addr contador, NULL
    push offset entrada 
    call trataString
    invoke atodw, addr entrada
    mov alturaCensura, eax

    
    ; --------- arquivo de saida
    invoke WriteConsole, outputHandle, addr msg5, sizeof msg5, addr contador, NULL
    invoke ReadConsole, inputHandle, addr arqsaid, sizeof arqsaid, addr contador, NULL
    push offset arqsaid
    call trataString
 
    invoke WriteConsole, outputHandle, addr newline, sizeof newline, addr contador, NULL

    ; --------- funcoes de leitura e criacao de arquivo
    
    invoke CreateFile, addr arqent, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov fInHandle, eax

    invoke CreateFile, addr arqsaid, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL          
    mov fOutHandle, eax

    ; --------- leitura e escrita do cabecalho

    invoke ReadFile, fInHandle, addr fileBuffer, 18, addr contador, NULL
    invoke WriteFile, fOutHandle, addr fileBuffer, 18, addr contador, NULL

    invoke ReadFile, fInHandle, addr fileBuffer, 4, addr contador, NULL
    mov eax, DWORD PTR [fileBuffer]
    imul eax, 3
    mov larg, eax    

    invoke WriteFile, fOutHandle, addr fileBuffer, 4, addr contador, NULL
    invoke ReadFile, fInHandle, addr fileBuffer, 4, addr contador, NULL
    mov eax, DWORD PTR [fileBuffer]
    mov alt, eax
    invoke WriteFile, fOutHandle, addr fileBuffer, 4, addr contador, NULL

    invoke ReadFile, fInHandle, addr fileBuffer, 28, addr contador, NULL
    invoke WriteFile, fOutHandle, addr fileBuffer, 28, addr contador, NULL
    mov eax, 0

    jmp defVariaveis

    ; ----------- 

defVariaveis:
    mov ebx, alt
    sub ebx, valory
    sub ebx, 1
    mov iniCens, ebx
    sub ebx, alturaCensura
    mov fimCens, ebx  
    mov ebx, larguraCensura
    add ebx, valorx
    imul ebx, 3
    mov larguraCensura, ebx
    mov ebx, valorx
    imul ebx, 3
    mov valorx, ebx
    mov ebx, 0
    jmp lerPixels

    
lerPixels:
    invoke ReadFile, fInHandle, addr linhaBuffer, larg, addr contador, NULL
    cmp contador, 0
    je fimLerPixels 

    mov ebx, alt     

    printf("\nebx: %d", ebx)
    cmp iniCens, ebx
    jle copyPixels
    cmp fimCens, ebx
    jge copyPixels

    push offset linhaBuffer
    push valorx
    push larguraCensura
    call censurar
    
    jmp copyPixels


copyPixels:
    invoke WriteFile, fOutHandle, addr linhaBuffer, larg, addr contador, NULL
    sub ebx, 1
    mov alt, ebx
    jmp lerPixels

fimLerPixels:
          
    invoke CloseHandle, fInHandle
    invoke CloseHandle, fOutHandle
 
    invoke ExitProcess, 0

    ; ------ Tratamento das strings 
    
trataString:
    pop ebx ; retorno
    pop esi ; endereco da string
tratamento:
    mov al, [esi] 
    inc esi 
    cmp al, 13
    jne tratamento 
    dec esi 
    xor al, al 
    mov [esi], al 
    jmp ebx 

censurar:    
    push ebp
    push ebx
    mov ebp, esp

    ; Parametros
    
    mov edi, [ebp+20]           ; linhaBuffer
    mov esi, DWORD PTR [ebp+16]  ; valorx
    mov ebx, DWORD PTR [ebp+12]  ; larguraCensura

loopInicial:
    mov eax, count2

    cmp count2, esi
    jl pedaco
    cmp count2, esi
    jge censurarLoop

pedaco:
    mov eax, count2
    inc eax
    mov count2, eax
    jmp loopInicial

censurarLoop:
    cmp count2, ebx
    jge censurarFim

    mov eax, count2
    
    mov byte ptr [edi], 0
    add edi, 1

    add count2, 1
    
    jmp censurarLoop

censurarFim:
    mov count2, 0
    pop ebx
    pop ebp
    ret 
   
  
end start