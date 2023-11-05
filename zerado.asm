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
    linhaBuffer db 6480 dup(0)
    linhabranca db 6480 dup(0)
    newline db 0ah, 0h
    preto db 0
    
    larg dd 4 dup(0)
    alt dd 4 dup(0)
    
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
    printf("largura: %d ", larg)

    

    invoke WriteFile, fOutHandle, addr fileBuffer, 4, addr contador, NULL
    invoke ReadFile, fInHandle, addr fileBuffer, 4, addr contador, NULL
    mov eax, DWORD PTR [fileBuffer]
    mov alt, eax
    printf("altura: %d ", alt)
    invoke WriteFile, fOutHandle, addr fileBuffer, 4, addr contador, NULL

    invoke ReadFile, fInHandle, addr fileBuffer, 28, addr contador, NULL
    invoke WriteFile, fOutHandle, addr fileBuffer, 28, addr contador, NULL

    ; ----------- 

    mov eax, alt
    sub eax, valory
    mov fimCens, eax
    sub eax, alturaCensura
    mov iniCens, eax
    printf("\ninicio censura: %d", iniCens)
    printf("\nfim censura: %d", fimCens)
    mov ecx, alt
    mov linha, ecx

    mov eax, valorx
    imul eax, 3
    mov valorx, eax
    printf("comeca em: %d", valorx)
    mov eax, larguraCensura
    imul eax, 3
    add eax, valorx
    mov larguraCensura, eax
    printf("termina em: %d", larguraCensura)
    
lerPixels:
    invoke ReadFile, fInHandle, addr linhaBuffer, larg, addr contador, NULL
    cmp contador, 0
    je fimLerPixels 

    mov ecx, linha

    printf("\nlinhas censura")
    
    cmp ecx, fimCens
    jg copyPixels
    cmp ecx, iniCens
    jl copyPixels

    printf("\nlinhas censura")
    mov edx, 0
    cmp ecx, fimCens
    jle linhaCensura
    jmp copyPixels

copyPixels:
    invoke WriteFile, fOutHandle, addr linhaBuffer, larg, addr contador, NULL
    sub linha, 1
    jmp lerPixels

linhaCensura:
    printf("\n entrou %d", edx)
    mov esi, offset linhaBuffer

    cmp valorx, edx
    jl inalterado
    cmp larguraCensura, edx
    jge inalterado
    cmp valorx, edx
    jge censurado

    ;mov eax, larguraCensura
    ;sub eax, valorx
    ;cmp eax, edx
    
    printf("\ncontador2: %d", linha)
    
    jmp copyPixels

fimLerPixels:

    printf("\nvalorx: %d, valory: %d, altura: %d, largura: %d, ecx: %d\n\n", valorx, valory, alturaCensura, larguraCensura, ecx)
          
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

inalterado:
    add edx, 1
    cmp larg, edx
    je copyPixels
    jmp linhaCensura
    
censurado:
    mov al, esi[edx]
    mov al, 0
    add edx, 1
    jmp linhaCensura
  
end start
