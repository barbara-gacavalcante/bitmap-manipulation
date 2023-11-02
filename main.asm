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
include \masm32\macros\macros.asm
 
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
    larg dd 4 dup(0)
    linhaBuffer db 6480 dup(0)
     
    newline db 0ah, 0h


    count dd 0     
    fInHandle dd 0
    fOutHandle dd 0
    inputHandle dd 0
    outputHandle dd 0
     
    contador dd 0 ; variavel caracteres escritos
      
; ----------------- variaveis declaradas -----------------
 
.data?
    valorx DWORD ?
    valory DWORD ?
    largura DWORD ?
    altura DWORD ?
 
; -------------------------= MAIN =--------------------------
 
.code

start:
 
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax
 
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax
 
     
    ; - arquivo de entrada
    invoke WriteConsole, outputHandle, addr msg0, sizeof msg0, addr contador, NULL
    invoke ReadConsole, inputHandle, addr arqent, sizeof arqent, addr contador, NULL
     
    ; - pegar entradas
    invoke WriteConsole, outputHandle, addr msg1, sizeof msg1, addr contador, NULL
    invoke ReadConsole, inputHandle, addr entrada, sizeof entrada, addr contador, NULL
    invoke atodw, addr entrada
    mov valorx, eax
 
    invoke WriteConsole, outputHandle, addr msg2, sizeof msg2, addr contador, NULL
    invoke ReadConsole, inputHandle, addr entrada, sizeof entrada, addr contador, NULL
    invoke atodw, addr entrada
    mov valory, eax
     
    invoke WriteConsole, outputHandle, addr msg3, sizeof msg3, addr contador, NULL
    invoke ReadConsole, inputHandle, addr entrada, sizeof entrada, addr contador, NULL
    invoke atodw, addr entrada
    mov largura, eax
    
    invoke WriteConsole, outputHandle, addr msg4, sizeof msg4, addr contador, NULL
    invoke ReadConsole, inputHandle, addr entrada, sizeof entrada, addr contador, NULL
    invoke atodw, addr entrada
    mov altura, eax
 
    invoke WriteConsole, outputHandle, addr msg5, sizeof msg5, addr contador, NULL
    invoke ReadConsole, inputHandle, addr arqsaid, sizeof arqsaid, addr contador, NULL
    invoke WriteConsole, outputHandle, addr newline, sizeof newline, addr contador, NULL
 
    ; - Tratamento da string do arquivo de entrada

    mov esi, offset arqent
tratamento:
    mov al, [esi]
    inc esi
    cmp al, 13
    jne tratamento
    dec esi
    xor al, al
    mov [esi], al

    inc count
    cmp count, 2
    je fimTrat
    mov esi, 0
    mov esi, offset arqsaid
    jmp tratamento
fimTrat:
    
    invoke CreateFile, addr arqent, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov fInHandle, eax
 
    invoke CreateFile, addr arqsaid, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL          
    mov fOutHandle, eax

    invoke ReadFile, fInHandle, addr fileBuffer, 18, addr contador, NULL
    invoke WriteFile, fOutHandle, addr fileBuffer, 18, addr contador, NULL
    invoke ReadFile, fInHandle, addr fileBuffer, 4, addr contador, NULL
    mov eax, DWORD PTR [fileBuffer]
    mov larg, eax
    invoke WriteFile, fOutHandle, addr fileBuffer, 4, addr contador, NULL
    invoke ReadFile, fInHandle, addr fileBuffer, 32, addr contador, NULL
    invoke WriteFile, fOutHandle, addr fileBuffer, 32, addr contador, NULL

    mov ecx, 0 

lerPixels:
    invoke ReadFile, fInHandle, addr linhaBuffer, sizeof linhaBuffer, addr contador, NULL
    
    cmp contador, 0
    jz fimLerPixels     ; jump if zero (sem bytes a serem escritos)
    
    invoke WriteFile, fOutHandle, addr linhaBuffer, contador, addr contador, NULL
    
    add ecx, contador
    
    jmp lerPixels
fimLerPixels:
          
    invoke CloseHandle, fInHandle
    invoke CloseHandle, fOutHandle
 
 
    invoke ExitProcess, 0
end start
