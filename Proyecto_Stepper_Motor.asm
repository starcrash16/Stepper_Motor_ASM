; PROYECTO FINAL: STEPPER MOTOR  
; REALIZADO POR  
; ALMADA DIAZ R.
; DE ANDA MEDINA R
; GONZALEZ RIVERA D.E.    

; 4TO SEMESTRE ISC UAA

#start= Stepper_motor_Bot.exe# ;llamada a plantillas que se usaran en el proyecto
#start= LED_Display_Bot.exe#  
#start= Proyecto_SFML.exe#

#make_bin#

jmp inicio

;=======================================================================================================
;                                            Inicio de Macros


; Macro para informacion de puerto 4 
; Funcionamiento grafico     
               
lectura_puerto_666 MACRO char
    MOV AL, char   
    MOV DX, 666
    OUT DX, AL
ENDM  

MACRO limpiarPantalla 
       MOV AH, 00h
       mov AL, 00h
       MOV CX, 
       MOV DX,184Fh
       MOV BH,57h 
       INT 10h
ENDM

;=======================================================================================================
; Creacion de vector de porcentajes

funcion_vec_porcentaje MACRO
    
    MOV DI, 0
    MOV DL, porcentaje
    MOV vec_porcentaje[DI], DL

ciclo:
    INC porcentaje
    CMP cont_aux, 4 
    JE suma_par
    JNE comparacion_mitad
    
suma_par:
    CMP porcentaje, 90
    JAE comparacion_mitad
    ADD porcentaje, 2
    MOV DL, 0
    MOV cont_aux, DL        
    JMP comparacion_mitad
            
comparacion_mitad:
    CMP DI, 62
    JAE suma_unidad
    JNE sumar_porcentaje

suma_unidad:
    INC porcentaje
    CMP porcentaje, 98
    JE suma_par_final
    JNE sumar_porcentaje
                
suma_par_final:
    ADD porcentaje, 2
    JMP sumar_porcentaje
                        
sumar_porcentaje:
    INC cont_aux
    INC DI 
             
    MOV DL, porcentaje
    MOV vec_porcentaje[DI], DL
    MOV DX, max_elementos
    CMP DI, DX
    JE salir
    JNE ciclo  
    
    salir:
    
ENDM    


;=======================================================================================================
;Macro para funcionamiento del porcentaje 
;Mandar informacion al port 199 (Display)

display_porcentaje MACRO
    MOV DI, CX
       
    MOV AL, vec_porcentaje[DI]
    MOV DX, 666
    OUT DX, AL
    OUT 199, AL 
       
ENDM  

print MACRO msj         ; mensaje
    MOV AH,09
    MOV DX,OFFSET msj
    INT 21h
ENDM

limpiar MACRO color
    MOV AH,0
    MOV AL,0
    INT 10h    
    ;SERVICIO 07 para cambiar el color 
    MOV AH,color
    MOV AL,0    ;# lineas desplazadas
    MOV BH,3h  ;color
    MOV CH,0   ;linea donde comienza
    MOV CL,0    ;columna donde comienza
    MOV DH,100   ;linea donde termina
    MOV DL,100   ;columna donde termina
    INT 10h
ENDM

    
;=======================================================================================================
;                                           FIN DE MACROS


;=======================================================================================================
;                                     Declaracion de Variables 

msj_graf1  db 10,13,"     AlmadaD | De AndaM | GonzalezR   $",
msj71          DB 10,13,"    ------------------------------",'$',10
msj_graf  db 10,13,"                 STEPPER              $",
msj1          DB 10,13,"      --------------------------",'$',10
msj2          DB 10,13,"      | ***** *** *** *** ***  |",'$',10
msj3          DB 10,13,"      | * * * * *  *  * * * *  |",'$',10
msj4          DB 10,13,"      | * * * * *  *  * * ***  |",'$',10
msj5          DB 10,13,"      | * * * * *  *  * * *  * |",'$',10
msj6          DB 10,13,"      | * * * ***  *  *** *  * |",'$',10
msj7          DB 10,13,"      --------------------------",'$',10
 
msj_continue  db 10,13,"      Que desea realizar? $"
msj_cont1     db 10,13,"      Revertir el proceso  [r]$"
msj_cont2     db 10,13,"      Continuar el proceso [c]$",10,13 
msj_espacio   db 13,10,'$'
msj_paro      db 10,13,13,"   Se ha detenido la puerta !!!  $",10,10,13,13           
msj_Abierto   db 10,13,"   La puerta se ha abierto!!! $",10,13
msj_Cerrado   db 10,13,"   La puerta se ha cerrado!!! $",10,13  
msj_paso_pc   db 10,13,"     Ingresa [p] para Paso completo $",10,13
msj_paso_pm   db 10,13,"     Ingresa [h] para Paso medio $",10,13
msj_direccion db 10,13,"     Ingresa '->' para cerrar $",10,13
msj_direccion_2 db 10,13,"     Ingresa '<-' para abrir $",10,13 
msj_resp        db 10,13, "     Input: $"   

msj_flecha_der DB "->",13,10,'$'
msj_flecha_izq DB "<-",13,10,'$'  

msj_menu_final             DB 10,13,"   Proceso terminado exitosamente $",10,13 
msj_menu_final_opc_1       DB 10,13,"     Cerrar Puerta  [->]$",10,13  
msj_menu_final_opc_2       DB 10,13,"     Abrir Puerta   [<-]$",10,13
msj_menu_final_opc_3       DB 10,13,"     Salir Programa [X]$",10,13
msj_direccion_no_cerrar    DB 10,13,"     No es posible cerrar... $"
msj_direccion_no_cerrar2   DB 10,13," ya que la puerta se encuentra cerrada$",10,13

;32 (decimal)(son 4 vueltas, para las 8 que pide el proyecto se necesitan 40h o 64d pasos)
steps_before_direction_change = 40h 
 
vec_porcentaje DB 66 DUP (?)
porcentaje db   0   

;Variables auxiliares
aux        dw   0 
cont_aux   db   0  
mov1       db   0 
bandera_dir db  0  
suma           DB   0  
divisor_2      DW 2  
tipo_de_mov    DB 0 
max_elementos  DW 41h
  

;=======================================================================================================
;                               Secuencias de activacion para la rotacion del motor
  
  
; MEDIO PASO                                                                                            
; sentido de las agujas del reloj
datcw    db 0000_0110b
         db 0000_0100b    
         db 0000_0011b
         db 0000_0010b

; MEDIO PASO
; sentido contrario a las agujas del reloj 
datccw   db 0000_0011b
         db 0000_0001b    
         db 0000_0110b
         db 0000_0010b

;------------------------------------------------

; PASO COMPLETO
; sentido de las agujas del reloj
datcw_fs db 0000_0001b
         db 0000_0011b    
         db 0000_0110b
         db 0000_0000b 
         
; PASO COMPLETO
; sentido contrario a las agujas del reloj
datccw_fs db 0000_0100b
          db 0000_0110b    
          db 0000_0011b
          db 0000_0000b 
          
;=======================================================================================================
;                                                  Start
;
;                                        Seleccion de modo de motor
;=======================================================================================================
inicio:

    funcion_vec_porcentaje
start:    
    limpiar 9
    print msj_graf1
    print msj71
    print msj_espacio 
    print msj_graf 
    print msj1
    print msj2
    print msj3
    print msj4
    print msj5
    print msj6
    print msj7
    print msj_espacio
    
    mov ax,0
    out 199,ax
    mov al, 200
    lectura_puerto_666 al
    
       
    ;Mensaje en pantalla    
    print msj_paso_pm
    print msj_paso_pc
    print msj_resp
    
    ;Input de usuario
    mov ah, 1h 
    int 21h  
    
    
    ;Eleccion paso completo
    cmp al, 'p' 
    je paso_completo
    
    ;Eleccion de medio paso
    cmp al, 'h'  
    je medio_paso
    jne start
    ;Si no ingresa una letra valida se vuelve a preguntar
    jmp start    
    
    ;Medio Paso  
    medio_paso: 
        MOV AL, 104
        lectura_puerto_666 AL
        mov bx, offset datccw   
        mov mov1,1 
        jmp start_direccion   
        
    paso_completo:
        MOV AL, 112         
        lectura_puerto_666 AL
        mov bx, offset datccw_fs  ; start from clock-wise full-step.
        mov mov1,2
        jmp start_direccion
    
;======================================================================================================   
; Direcciones   
; Para abrir, tendra que ser sentido antihorario
; Para cerrar, sentido de reloj 
;======================================================================================================    

start_direccion:
    ;Mensaje en pantalla
    print msj_direccion_2
    ;Mensaje de explicacion
    print msj_espacio 
    print msj_direccion_no_cerrar
    print msj_direccion_no_cerrar2
    ;Mensaje en pantalla
    print msj_resp
    
    ;Input de usuario         
    xor ax,ax
    int 16h      
    
    ;Sentido antihorario (Abrir)
    cmp ah,4Bh
    je  flechaI
    
    
    ;Tecla invalida
    jne limpiarPantStart_direccion
    
    
        ;Flecha Izquierda
        flechaI:
            ;Mensaje en pantalla de flecha
            print msj_flecha_izq 
            jmp control          
            
    limpiarPantStart_direccion:
        MOV AH,0   ;limpia pantallas
        MOV AL,0
        INT 10h
    jmp start_direccion          
    
;======================================================================================================   
;  Inicio de simulacion de motor para abrir 
   
    modificar_imagen:
        out 7, al 
        JMP sig_mov
    
control: 
    ; inicio de contadores
    mov si, 0
    mov cx, 0 

next_step:   
    
    wait:   
        in al, 7     
        test al, 10000000b
        jz wait       
 
    ; Mostrar el valor de al antes de escribirlo en el puerto 7
    mov dx, 3F8h ; Puerto serie COM1
    mov ah, al
    mov al, '0'
    out dx, al
    mov al, ah
    out dx, al
    
    ;Se asigna a al el bit con el que iniciar el motor
    ;(este ya incluye direccion y tipo de paso)
    mov al, [bx][si] 
    out 7, al 
    ;CMP al, 10000000b
    ;JNE modificar_imagen
     

    sig_mov:
        ;Incremento de SI para que el siguiente ciclo genere el movimiento      
        inc si 
        
        ;Comparamos SI con 4
        cmp si, 4 
        ; Si es menor nos vamos al siguiente paso  
        jb next_step
        ;Si es mayor se reiniciar si y se incrementa cx
        mov si, 0  
        
        inc cx 
        display_porcentaje       
        
        
            mov dl,0FFh 
            mov ah,06
            int 21h     
            
            ;Comparar el caracter ingresado por teclado con el Escape (Esc)
            cmp al,"s"      
            je  paro
            
            ;cuando se generen el numero de movimientos requeridos se cambia direccion           
            cmp cx, 64
            jb  next_step 
            ; si no nos colocamos en el siguiente paso
            je  proceso_terminado_abrir    
                        
                        
            proceso_terminado_abrir:
                
                ;Mensaje en pantalla, puerta totalmente abierta!
                
                MOV AL, 100
                MOV porcentaje, AL
                OUT 199, AL      
                
                print msj_espacio
                print msj_Abierto 
             
                MOV DL, 1
                MOV tipo_de_mov, DL
                
                ;Menu fin 
                
                JMP menu_opcion_fin 
    

;======================================================================================================
; CONDICION DE PARO EN MODO ABRIR, POR MEDIO DE TECLA 'S'
    
paro:                    

    lectura_puerto_666 's'
    ;Mensaje en pantalla 
    print msj_paro
    print msj_espacio
    print msj_cont1
    print msj_cont2 
    print msj_continue
    
    ;Input de usuario
    mov ah,01   
    int 21h
               
    ;Seguir el proceso
    cmp al,'c'
    je next_step        
    
    ;Revertir el proceso   
    cmp al,'r'   
    ; Se activa 0 ya que se cerrara la puerta
    mov bandera_dir, 0
    je revertir
    jne limpiarPantParo ;;En caso de respuesta invalida
    
    limpiarPantParo: 
       MOV AH,0
       MOV AL,0
       INT 10h
    jmp paro
;======================================================================================================
;Revertir el ciclo, 
    
    ;Mov1 y Mov2 declarados en "Seleccion de modo de motor" (Start), denotaran el tipo de paso
    revertir:     
        
        ;En caso de ser paso medio
        cmp mov1,1
        je  cambio_pasomedio
         
        ;En caso de ser paso completo
        cmp mov1,2
        je  cambio_pasocompleto
        
        
        cambio_pasomedio: 
            ;Bandera en 1 = Direccion izquierda (Abriendose)
            cmp bandera_dir,0     
            ;Se cambia el sentido
            je  sentido_AH       
            ;Modificamos la dir, para el futuro volverla a cambiarla
            MOV bandera_dir, 0     
            ; Sentido antihorario, (Abrir)
            mov bx,offset datccw
            jmp next_step 
        
        
        ;Paso Medio, en sentido Horario
        sentido_AH:
            MOV bandera_dir, 1
            ; Cerrar
            MOV bx,offset datcw     
            JMP next_step_cerrar   
            
           
        cambio_pasocompleto:
            ;Bandera en 1 = Direccion izquierda (Abriendose)
            CMP bandera_dir,0
            JE  sentidoahc
            INC bandera_dir     
            ; Sentido antihorario, (Abrir)
            MOV bx,offset datccw_fs
            JMP next_step  
         
        ;Paso Completo, en sentido Horario            
        sentidoahc:
            DEC bandera_dir
            ;Cerrar
            mov bx,offset datcw_fs      
            jmp next_step_cerrar    
    
;====================================================================================================== 
; Inicio de Simulacion de cerrar el motor   
    
    modificar_imagen_resta:
        out 7, al
        JMP sig_mov_cerrar
    
    control_resta:   
        
        mov si, 0
        mov cx, 40h   
        mov dl, 100
        mov porcentaje, dl
           
    next_step_cerrar:  
        
        wait_cerrar:
            in al,7
            test al, 10000000b
            jz wait_cerrar 

    ;Se asigna a el bit con el que iniciar el motor
    ;(este ya incluye direccion y tipo de paso)
    mov al, [bx][si]
    CMP AL, 10000000b
    JNE modificar_imagen_resta

    sig_mov_cerrar:
    ;Incremento de SI para que el siguiente ciclo genere el movimiento      
    inc si 
    
    ;Comparamos SI con 4
    cmp si, 4 
    ; Si es menor nos vamos al siguiente paso  
    jb next_step_cerrar
    ;Si es mayor se reiniciar si y se incrementa cx
    mov si, 0  
    
    
    dec cx 
    display_porcentaje
    
    ;espera por tecla y compara (Condicion de paro)
    mov dl,0FFh 
    mov ah,06
    int 21h     
    cmp al,"s"      ;Comparar el caracter ingresado por teclado con el Escape (Esc)
    je  paro_cerrar
    
    ;cuando se generen el numero de movimientos requeridos se cambia direccion
    cmp cx, 0
    ja  next_step_cerrar ; si no nos colocamos en el siguiente paso
    je proceso_terminado_cerrar
        
        proceso_terminado_cerrar:                       
        
        ;Mensaje en pantalla, puerta totalmente cerrada!    
            MOV AL, 0
            MOV porcentaje, AL
            OUT 199, AL 
            print msj_espacio
            print msj_Cerrado 
            MOV DL, 0
            MOV tipo_de_mov, DL      

            JMP menu_opcion_fin

    
;======================================================================================================
; CONDICION DE PARO EN MODO CERRAR, POR MEDIO DE TECLA 'S'
    
paro_cerrar:
 
    lectura_puerto_666 's'
    ;Mensaje en pantalla
    print msj_paro
    ;Mensaje en pantalla
    print msj_continue    
    print msj_cont1
    print msj_cont2
    ;Input de usuario
    mov ah,01   
    int 21h
               
    ;Seguir el proceso
    cmp al,'c'
    je next_step_cerrar        
    
    ;Revertir el proceso   
    cmp al,'r' 
    mov bandera_dir,1
    je revertir 
    
    ;En caso de respuesta invalida
    jne limpiarPantParo_cerrar      
    
    limpiarPantParo_cerrar:
       MOV AH,0
       MOV AL,0
       INT 10h
    jmp paro_cerrar

;======================================================================================================    

menu_opcion_fin: 

    CMP tipo_de_mov,1
    JE  cerrar_puerta
    JNE abrir_puerta
    
        cerrar_puerta: 
             
            print msj_espacio
            print msj_menu_final_opc_1
            print msj_menu_final_opc_3
            print msj_resp
            
            xor ax,ax
            int 16h      
            
            ;Sentido de reloj (Cerrar)
            cmp ah, 4Dh  
            je  flechaD_fin 

            cmp al,'X'
            JE fin  
            
            cmp al, 'x'
            JE fin    
            jne limpiaPant_fin
            
            limpiaPant_fin:
               MOV AH,0
               MOV AL,0
               INT 10h
            jmp cerrar_puerta 
            
            ;Flecha Derecha
                flechaD_fin:
                    ;Mensaje en pantalla de flecha
                    print msj_flecha_der
                    jmp seleccion_modo_cerrar 
            
        abrir_puerta:
            print msj_espacio  
            print msj_menu_final_opc_2
            print msj_menu_final_opc_3
            print msj_resp

            xor ax,ax
            int 16h  
            
             cmp al,'X'
            JE fin
            
            cmp al, 'x'
            JE fin      
            jne start
            
            ;Sentido de reloj (Abrir)
            cmp ah, 4Bh  
            je  flechaI_abrir 
            
            jmp cerrar_puerta    ;Flecha Izquierda
                flechaI_abrir:
                    ;Mensaje en pantalla de flecha
                    print msj_flecha_izq             
                    jmp seleccion_modo_abrir 
                        

;======================================================================================================
; Una vez terminado el ciclo completo de abrir
; Menu final de abrir
;======================================================================================================

    
 seleccion_modo_cerrar:
    
    print msj_espacio
    print msj_paso_pc
    print msj_paso_pm
    print msj_resp 
    
    ;Input de usuario
    mov ah, 1h 
    int 21h  
    
    ;Eleccion paso completo
    cmp al, 'p' 
    je paso_completo_cerrar 
    
        paso_completo_cerrar:
            mov bx, offset datcw_fs  ; start from clock-wise full-step.
            mov mov1,2
            jmp control_resta         
    
    ;Eleccion de medio paso
    cmp al, 'h'  
    je medio_paso_cerrar 
    
         medio_paso_cerrar: 
            mov bx, offset datcw   ; start from clock-wise full-step.
            mov mov1,1
            jmp control_resta
            
    
    JNE  limpiarPantSeleccion_modo_cerrar 
    
    limpiarPantSeleccion_modo_cerrar:
        MOV AH,0
        MOV AL,0
        INT 10h
    jmp seleccion_modo_cerrar
       
    
    
;======================================================================================================
; Una vez terminado el ciclo completo de cerrar
; Menu final de cerrado
;======================================================================================================

seleccion_modo_abrir:
    
    print msj_espacio  
    print msj_paso_pc
    print msj_paso_pm
    print msj_resp
    
    ;Input de usuario
    mov ah, 1h 
    int 21h  
    
    ;Eleccion paso completo
    cmp al, 'c' 
    je paso_completo_abrir 
    
        paso_completo_abrir:
            mov bx, offset datccw_fs   ; start from clock-wise full-step.
            mov mov1,2
            jmp control         
    
    ;Eleccion de medio paso
    cmp al, 'h'  
    je medio_paso_abrir 
    
         medio_paso_abrir: 
            mov bx, offset datccw    ; start from clock-wise full-step.
            mov mov1,1
            jmp control
            
    
    JNE  limpiarPantSeleccion_modo_abrir   
    
    limpiarPantSeleccion_modo_abrir:
       MOV AH,0
       MOV AL,0
       INT 10h
    JMP seleccion_modo_abrir

fin:    
    
    lectura_puerto_666 'x'
    MOV AH,4Ch
    INT 21h

END