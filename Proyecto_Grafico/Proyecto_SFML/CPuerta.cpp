#include "CPuerta.h"

// Constructor
CPuerta::CPuerta()
    : window(sf::VideoMode(1000, 700), "Stepper Motor Door", sf::Style::Titlebar),
    paisaje(Vector2f(992.0f, 696.0f)),
    puerta_L(Vector2f(237.0f, 466.0f)),
    puerta_D(Vector2f(237.0f, 466.0f))

{
    cargar_Texturas();  // Cargar texturas al inicializar
    setupOrigins(); 
    cargar_Shapes();   // Configurar formas al inicializar
    render();
    
}

// Método para cargar las texturas
void CPuerta::cargar_Texturas() {
    std::string texturePath = "C:\\Emu_puerto\\imagenes\\jardin.png";
    std::string puertaPath = "C:\\Emu_puerto\\imagenes\\puerta.png";

    // Cargar la textura del paisaje
    if (!paisajeTexture.loadFromFile(texturePath)) {
        std::cerr << "Error: No se pudo cargar la textura desde " << texturePath << std::endl;
    }

    // Cargar la textura de la puerta
    if (!puertaTextura.loadFromFile(puertaPath)) {
        std::cerr << "Error: No se pudo cargar la textura desde " << puertaPath << std::endl;
    }
}

// Método para establecer el origen de las formas
void CPuerta::setupOrigins() {
    //paisaje.setOrigin(-2, -1);
    puerta_L.setOrigin(-258.0f, -134.0f);
    puerta_D.setOrigin(-497.0f, -134.0f);
    window.setPosition(sf::Vector2i(900, 50)); // Coordenadas (100, 100)
}


// Método para configurar las formas con las texturas
void CPuerta::cargar_Shapes() {
    paisaje.setTexture(&paisajeTexture);
    puerta_L.setTexture(&puertaTextura);
    puerta_D.setTexture(&puertaTextura);
}


void CPuerta::render() {
    window.clear();  // Limpiar la ventana
    window.draw(paisaje);   // Dibujar el paisaje
    window.draw(puerta_L);  // Dibujar la puerta izquierda
    window.draw(puerta_D);  // Dibujar la puerta derecha

    window.display();  // Mostrar lo que se ha dibujado en la ventana
}

void CPuerta::processEvents() {
    sf::Event event;
    while (window.pollEvent(event)) {
        if (event.type == sf::Event::Closed) {
            window.close();
        }
        break; // Debería estar dentro del if

    }
}


void CPuerta::movimiento(float valor) {
    puerta_L.move(-(valor), 0.0f);
    puerta_D.move(valor, 0.0f);
    render();
}

void CPuerta::run(int escenario, int porcentaje) {
    int i = 0;
    while (window.isOpen()) {
        processEvents();
        if (porcentaje > porcentaje_ant) {
            porcentaje_ant = porcentaje;
            switch (escenario)
            {
            case 112:
                // Paso completo
                if (bandera_modo != 112 && porcentaje == 97) {
                    movimiento(1.8);
                }
                movimiento(3);
                movimiento(3);
                Sleep(700);
                break;
            case 104:
                //Paso medio
                if (bandera_modo != 104 && porcentaje == 97) {
                    movimiento(1.8);
                }
                while (i < 4) {
                    movimiento(.4765);
                    movimiento(.4765);
                    i++;
                }
                break;
            default:
                break;
            }
        }
        else if (porcentaje < porcentaje_ant) {
            porcentaje_ant = porcentaje;
            switch (escenario)
            {
            case 112:
                if (bandera_modo != 112 && porcentaje == 0) {
                    movimiento(-1.8);
                }
                // Paso completo
                movimiento(-3);
                movimiento(-3);
                Sleep(700);
                break;
            case 104:
                //Paso medio
                if (bandera_modo != 104 && porcentaje == 0) {
                    movimiento(-1.8);
                }
                while (i < 4) {
                    movimiento(-.4765);
                    movimiento(-.4765);
                    i++;
                }
                break;
            default:
                //render();
                break;
            }
        }
        break;
    }
    if (porcentaje == 97 || porcentaje == 0) {
        bandera_modo = escenario;
    }
}
