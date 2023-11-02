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

; ----------------- variaveis declaradas -----------------

.data
    msg0 db "Digite o nome do arquivo de entrada:", 0ah, 0h
    msg1 db "Digite a coordenada X:", 0ah, 0h
    msg2 db "Digite a coordenada Y:", 0ah, 0h
    msg3 db "Digite a largura:", 0ah, 0h
    msg4 db "Digite a altura:", 0ah, 0h
    msg5 db "Digite o nome do arquivo de saida:", 0ah, 0h

    entrada db 4 dup(0)
    arqent db 40 dup(0)
    arqsaid db 40 dup(0)

    newline db 0ah, 0h
    inputHandle dd 0
    outputHandle dd 0 ; variavel handle da saida
    contador dd 0 ; variavel caracteres escritos

    ;constante dd 42, 0

; ----------------- variaveis inicializadas ---------------

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
    
    ; pegar entradas
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

    ; - 
    push 





    ;invoke WriteConsole, outputHandle, addr entx, sizeof entx, addr contador, NULL
    invoke WriteConsole, outputHandle, addr newline, sizeof newline, addr contador, NULL

    

    ;invoke WriteConsole, outputHandle, addr newline, sizeof newline, addr contador, NULL
    ;invoke WriteConsole, outputHandle, addr msg2, sizeof msg2, addr contador, NULL
    ;invoke WriteConsole, outputHandle, addr msg3, sizeof msg3, addr contador, NULL
    ;invoke WriteConsole, outputHandle, addr msg4, sizeof msg4, addr contador, NULL


    invoke ExitProcess, 0
    
  end start