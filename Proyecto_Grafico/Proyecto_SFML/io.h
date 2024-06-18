#pragma once
#include <iostream>
#include <string.h>
#include <stdlib.h>
#include <fstream>
const char sIO_FILE[] = "C:\\Emu_puerto\\emu8086.io";

unsigned char READ_IO_BYTE(long lPORT_NUM)
{
    unsigned char tb;
    char buf[500];
    unsigned int ch;
    strcpy(buf, sIO_FILE);
    FILE* fp;
    fp = fopen(buf, "r+");
    if (!fp) {
        std::cout << "Emu8086.io no fue encontrado";
        return 0;
    }
    // Read byte from port:
    fseek(fp, lPORT_NUM, SEEK_SET);
    ch = fgetc(fp);
    fclose(fp);
    tb = ch;
    return tb;
}