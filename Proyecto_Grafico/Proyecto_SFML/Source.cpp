#include <SFML/Graphics.hpp>
#include <windows.h>
#include <iostream>
#include <fstream>
#include "CPuerta.h"
#include "io.h"

using namespace sf;
using namespace std;

void checkAndReplaceCharacter(fstream& ,CPuerta& ,int , int& , int&);

int main()
{
  
    system("mode con: cols=23 lines=10");
    cout << "Para cerrar la ventana grafica\n,de las puertas cerrar \ndesde aqui";
    // Borramos cualquier inforamación que hubiera en el emu8086.io
    
    ofstream file_io("C:\\Emu_puerto\\emu8086.io", std::ios::trunc);
    file_io.close();
    ofstream  archivoEntrada("C:\\Emu_puerto\\emu8086.txt", std::ios::out);

    unsigned char lectura = READ_IO_BYTE(666);
    int valor = 0, cont = 0, aux = 0;
    CPuerta control_puerta;
    
    do {
        valor = static_cast<unsigned int>(lectura);
        if (valor != 200 && lectura != 's') {
            fstream archivoEntrada("C:\\Emu_puerto\\emu8086.txt", std::ios::in | std::ios::out | std::ios::app);
            
            checkAndReplaceCharacter(archivoEntrada, control_puerta, valor, cont, aux);
        }
        archivoEntrada.close(); 
        Sleep(15);
        lectura = READ_IO_BYTE(666);
    } while (lectura != 'x');
    exit(1);
    return 0;
}

void checkAndReplaceCharacter(fstream& archivoEntrada, CPuerta &control_puerta, int newChar, int& cont, int& aux) {
    int lectura_Actual[2] = { 0,0 };

    if (newChar == 104 && cont == 0 || newChar == 112 && cont == 0) {
        ofstream archivoSalida("C:\\Emu_puerto\\emu8086.txt", ios::trunc);
        archivoSalida << newChar << " " << 0;
        cont++;
        archivoSalida.close();
    }
    else if (cont > 0) {
        if (archivoEntrada.is_open()) {
            archivoEntrada.seekg(0, ios::beg);
            archivoEntrada >> lectura_Actual[0] >> lectura_Actual[1];
            archivoEntrada.close();
        }
        if (lectura_Actual[0] != newChar) {
            ofstream archivoSalida("C:\\Emu_puerto\\emu8086.txt", ios::trunc);
            if (newChar == 112 || newChar == 104) {
                lectura_Actual[0] = newChar;
                archivoSalida << lectura_Actual[1] << " " << lectura_Actual[0];
            }
            else {
                switch (lectura_Actual[0])
                {
                    // Paso completo = p
                case 112:
                    
                    archivoSalida << 112 << " " << newChar;
                    control_puerta.run(112, newChar);
                    aux = newChar;
                    break;
                    // Paso medio = h    
                case 104:
                    archivoSalida << 104 << " " << newChar;
                    control_puerta.run(104, newChar);
                    aux = newChar;
                    break;
                default:
                    archivoSalida << lectura_Actual[0] << " " << lectura_Actual[1];
                    break;
                }
            }
            archivoSalida.close();
        }

    }
}

