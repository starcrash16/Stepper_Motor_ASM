#start=stepper_motor.exe#

.model small

;Segmento de pila
.stack 

;Segmento de datos
.data
  
    steps_before_direction_change = 20h ; 32 (decimal)
    
    msj_paso db 10,13,"Ingresar '1' para PASO COMPLETO o '0' para MEDIO PASO: $",10,13
    msj_direccion db 10,13,"Ingresar '1' para sentido de reloj o '0' para sentido contrario: $",10,13
 
    ; Secuencia de activacion para rotar el motor
    datcw    db 0000_0110b
             db 0000_0100b    
             db 0000_0011b
             db 0000_0010b

    ; bin data for counter-clock-wise
    ; half-step rotation:
    datccw   db 0000_0011b
             db 0000_0001b    
             db 0000_0110b
             db 0000_0010b


    ; bin data for clock-wise
    ; full-step rotation:
    datcw_fs db 0000_0001b
             db 0000_0011b    
             db 0000_0110b
             db 0000_0000b

    ; bin data for counter-clock-wise
    ; full-step rotation:
    datccw_fs db 0000_0100b
              db 0000_0110b    
              db 0000_0011b
              db 0000_0000b
    
;Segmento de codigo
.code      

inicio:    

    MOV AX,@DATA  
    MOV DS,AX
    
    mov ah, 9
    mov dx, offset msj_paso
    int 21h ;mensaje para el tipo de paso que usara el programa
    
    MOV AH, 01h     
    int 21h  ;respuesta del usuario
    
    MOV SI, 0
    MOV CX, 0 ; step counter
    
    cmp al, '1'  ; eleccion de medio paso
    je medio_paso
    
    cmp al, '0' ;eleccion paso completo
    je paso_completo          
    
    
medio_paso: 
    ;Direccion modo medio paso
    mov bx, offset datcw ; start from clock-wise half-step.
    jmp start_direccion_mp

paso_completo:
    ;Direccion para el paso completo
    mov bx, offset datcw_fs ; start from clock-wise full-step.
    jmp start_direccion_pcmp
    
start_direccion_mp:  

    mov ah, 9
    mov dx, offset msj_direccion
    int 21h   
    
    mov ah, 01h
    int 21h  ; read user input
    
    cmp al, '1'
    je control
    
    cmp al, '0'
    mov bx, offset datccw 
    jmp control
    
    jmp start_direccion_mp   ; tecla invalida, el programa vuelve a preguntar
    
    
start_direccion_pcmp:
    
    mov ah, 09h
    mov dx, offset msj_direccion
    int 21h
    
    cmp al, '1'  ;al sentido del reloj
    je control
    
    cmp al, '0' ; al sentido contrario del reloj
    mov bx, offset datccw_fs 
    je  start_direccion_pcmp
    
    jmp start_direccion_pcmp   ; tecla invalida, el programa vuelve a preguntar             
                
control:    
    MOV SI, 0
    MOV CX, 0 ; step counter

next_step:
    ; motor sets top bit when it's ready to accept new command
    wait:   
        IN AL, 7     
        TEST AL, 10000000b
        JZ wait

    MOV AL, [BX][SI]
    OUT 7, AL

    INC SI

    CMP SI, 4
    ;JUMP if Below
    JB next_step
    
    ;SI ya llego a 4
    MOV SI, 0

    INC CX
    CMP CX, steps_before_direction_change
    JB next_step

    MOV CX, 0
    ADD BX, 4 ; next bin data

    CMP BX, offset datccw_fs
    JBE next_step

    MOV BX, offset datcw ; return to clock-wise half-step.

    JMP next_step

    MOV AH, 4Ch
    INT 21h 

END inicio