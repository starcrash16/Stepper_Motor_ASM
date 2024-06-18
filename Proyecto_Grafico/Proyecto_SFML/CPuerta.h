#pragma once
#ifndef CPuerta_hpp
#define CPuerta_hpp
#include <SFML/Graphics.hpp>
#include <iostream>
#include <windows.h>
using namespace sf;

class CPuerta {
public:
	CPuerta();
	void run(int, int);
	int veces = 0;
	int bandera_modo = 0;
	int porcentaje_ant = 0;
	void render();

private:
	void cargar_Texturas();
	void cargar_Shapes();
	void setupOrigins();  // Método para establecer el origen de las formas
	void processEvents(); // Método para procesar eventos
	void movimiento(float);
	RenderWindow window;
	RectangleShape paisaje;
	RectangleShape puerta_L;
	RectangleShape puerta_D;
	Texture paisajeTexture;
	Texture puertaTextura;
	int contador = 0;
};
#endif
