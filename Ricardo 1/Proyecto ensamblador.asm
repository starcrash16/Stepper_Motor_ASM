#start=stepper_motor.exe#

#make_bin#

steps_before_direction_change = 20h ; 32 (decimal)(son 4 vueltas, para las 8 que pide el proyecto se necesitan 40h o 64d pasos)

jmp start

; ========= data =============== 

msj_paso db 10,13,"Enter 'c' for full-step or 'h' for half-step: $",10,13
msj_direccion db 10,13,"Enter 'c' for clockwise or 'a' for anticlockwise: $",10,13
; sentido del reloj                                                                  

; medio paso:
datcw    db 0000_0110b      ;6
         db 0000_0100b      ;4
         db 0000_0011b      ;3
         db 0000_0010b      ;2

; al contrario del reloj
; medio paso:
datccw   db 0000_0011b      ;3
         db 0000_0001b      ;1
         db 0000_0110b      ;6
         db 0000_0010b      ;2


; paso completo al sentido del reloj
datcw_fs db 0000_0001b
         db 0000_0011b    
         db 0000_0110b
         db 0000_0000b

; paso completo al sentido contrario del reloj
datccw_fs db 0000_0100b
          db 0000_0110b    
          db 0000_0011b
          db 0000_0000b

start:

    mov ah, 9
    mov dx, offset msj_paso
    int 21h ;mensaje para el tipo de paso que usara el programa

    mov ah, 1
    int 21h  ;respuesta del usuario

    cmp al, 'c' ;eleccion paso completo
    je paso_completo

    cmp al, 'h'  ; eleccion de medio paso
    je medio_paso

    jmp start   ; si no ingresa una letra valida se vuelve a preguntar 

medio_paso:
    mov bx, offset datcw ; start from clock-wise half-step.
    jmp start_direccion

paso_completo:

    mov bx, offset datcw_fs ; start from clock-wise full-step.
    jmp start_direccion
    
start_direccion:
    ;todavia no se como hacer la entrada de las teclas validas de las flechas
    mov ah, 9
    mov dx, offset msj_direccion
    int 21h   
    
    mov ah, 1
    int 21h  ; read user input
    cmp al, 'c'  ;al sentido del reloj
    je control
    
    cmp al, 'a' ; al sentido contrario del reloj
    je direc_invertida
    
    jmp start_direccion   ; tecla invalida, el programa vuelve a preguntar
    
control:
    mov si, 0
    mov cx, 0 ; inicio de contadores

next_step:
    ; motor sets top bit when it's ready to accept new command
    wait:   in al, 7 ; se hace uso del puerto 7 por la plantilla que se esta utilizando el cual hace uso de este mismo    
            test al, 10000000b ;bit de testeo para comprobar la funcionalidad del puerto
            jz wait ;si no se reconoce vuelve a comprobarlo
    
    mov al, [bx][si] ;se asigna a al el bit con el que iniciar el motor(este ya incluye direccion y tipo de paso)
    out 7, al ;se manda la senal al puerto 
    
    inc si ;incremento de si para que el siguiente ciclo genere el movimiento 
    
    cmp si, 4  ;comparamos si con 4, si es menor nos vamos al siguiente paso
    jb next_step
    mov si, 0  ;si es mayor se reiniciar si y se incrementa cx
    
    inc cx
    cmp cx, steps_before_direction_change;cuando se generen el numero de movimientos requeridos se cambia direccion
    jb  next_step ; si no nos colocamos en el siguiente paso
    
    mov cx, 0
    add bx, 4 ;agregamos 4 en bx para pasar al siguiente conjunto de datos binarios
    
    cmp bx, offset datccw_fs;comprobamos el tipo de paso para cambia la direccion
    jbe next_step
    
    mov bx, offset datcw ;si es medio paso se vuelve a colocar en bx este conjunto de datos bin
    
    jmp next_step
    
direc_invertida:
    mov bx, offset datccw ;este apartado sirve para iniciar con la direccion invertida
    
    jmp control