#start=stepper_motor.exe#

.model small

;Segmento de pila
.stack 

;Segmento de datos
.data
    var db 0 ; Variable de prueba
    steps_before_direction_change = 20h ; 32 (decimal)
    
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

    MOV BX, offset datcw ; start from clock-wise half-step.
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
    JB next_step

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
