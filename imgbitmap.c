/*USAR O CAMINHO DAS IMAGENS, TANTO NO INPUT DO ARQUIVO DE ENTRADA, QUANTO NO DE SAÍDA*/
#include <stdio.h>
#include <stdlib.h>

void censurar(char linhaBuffer[], int x, int larg) {
    for (int i = 0; i < larg; i++) {
        linhaBuffer[x + i] = 0;
    }
}

int main() {
    char arqEntrada[100];
    char arqSaida[100];
    int x, y, height, width;

    printf("Informe o caminho do arquivo de entrada: ");
    scanf("%99s", arqEntrada);

    printf("Informe as coordenadas da área a ser censurada (X Y): ");
    scanf("%d %d", &x, &y);

    printf("Informe a altura da censura: ");
    scanf("%d", &height);

    printf("Informe a largura da censura: ");
    scanf("%d", &width);

    printf("Qual será o nome do arquivo de saída? ");
    scanf("%99s", arqSaida);

    FILE *fptrIn;
    FILE *fptrOut;

    fptrIn = fopen(arqEntrada, "rb");
    fptrOut = fopen(arqSaida, "wb");

    if (fptrIn == NULL || fptrOut == NULL) {
        printf("Não foi possível abrir os arquivos. Encerrando o programa.\n");
        return 1;
    }

    printf("Arquivo aberto com sucesso.\n");

    char buffer[54];
    size_t bytesLidos;

    bytesLidos = fread(buffer, 1, 54, fptrIn); 
    if (bytesLidos != 54) {
        printf("Erro ao ler o cabeçalho do arquivo de entrada. Encerrando o programa.\n");
        fclose(fptrIn);
        fclose(fptrOut);
        return 1;
    }
    fwrite(buffer, 1, 54, fptrOut); 

    int arqWidth = *(int*)(buffer + 18); 

    char linhaBuffer[arqWidth * 3];
    size_t bytesPorLinha = arqWidth * 3;

    for (int i = 0; i < arqWidth; i++) {
        bytesLidos = fread(linhaBuffer, 1, bytesPorLinha, fptrIn);

        if (bytesLidos != bytesPorLinha) {
            printf("Erro ao ler uma linha da imagem. Encerrando o programa.\n");
            fclose(fptrIn);
            fclose(fptrOut);
            return 1;
        }

        if (i >= y && i < y + height) {
            censurar(linhaBuffer, x * 3, width * 3); 
        }

        fwrite(linhaBuffer, 1, bytesPorLinha, fptrOut);
    }

    char pixelBuffer[1024];
    while (1) {
        bytesLidos = fread(pixelBuffer, 1, sizeof(pixelBuffer), fptrIn);
        if (bytesLidos == 0) {
            break;
        }
        fwrite(pixelBuffer, 1, bytesLidos, fptrOut);
    }

    fclose(fptrIn);
    fclose(fptrOut);

    printf("Censura concluída com sucesso. Imagem salva em %s\n", arqSaida);

    return 0;
}
