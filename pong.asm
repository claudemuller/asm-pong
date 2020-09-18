stack segment para stack
    db 64 dup (' ')
stack ends

data segment para 'data'
    ball_x dw 0ah       ;set x pos 
    ball_y dw 0ah       ;set y pos
    ball_size dw 04h    ;size of ball (4x4)
    ball_vel_x dw 05h
    ball_vel_y dw 02h

    time_aux db 0       ;variable used to check time changed

    comment @
        ;dw is a 16bit number the above two are used in 16bit registers (cx,dx)
        ;db is a 8bit number and can be stored in xL or xH
    @
data ends

code segment para 'code'
    main proc far
    assume cs:code,ds:data,ss:stack ;assume code, data and stack segments as their respective registers
        push ds         ;push to the stack the ds register
        sub ax,ax       ;clean the ax register
        push ax         ;push ax to the stack
        mov ax,data     ;save data content in ax register
        mov ds,ax       ;save ax content in the ds segment
        pop ax          ;release top item of stack
        pop ax          ;pop again

        call clear_screen

        check_time:
            mov ah,2ch      ;get system time - ch=hour, cl=minute, dh=sec, dl=1/100sec
            int 21h

            cmp dl,time_aux ;is current time equl to previous time (time_aux)
            je check_time   ;if it is the same, check again

            mov time_aux,dl ;update time_aux with time now

            call clear_screen

            call move_ball
            call draw_ball  ;draw only if 1/100 has passed

            jmp check_time

        ret
    main endp

    clear_screen proc near
        mov ah,00h      ;set conf to video mode
        mov al,13h      ;choose video mode
        int 10h         ;execute conf/command with int

        mov ah,0bh      ;set conf to bgcolour
        mov bh,00h      ;^
        mov dl,00h      ;set to black
        int 10h         ;execute conf/command with int
    
        ret
    clear_screen endp

    move_ball proc near
        mov ax,ball_vel_x
        add ball_x,ax
        mov ax,ball_vel_y
        add ball_y,ax

        ret
    move_ball endp

    draw_ball proc near
        mov cx,ball_x   ;set initial x to ball_x ;cx is a 16bit register
        mov dx,ball_y   ;set initial x to ball_y ;dx is a 16bit register

        draw_ball_horizontal:
            mov ah,0ch                  ;set conf to draw pixel
            mov al,0fh                  ;set colour to white
            mov bh,00h                  ;set page number
            int 10h

            inc cx                      ;increment x
            mov ax,cx                   ;store cx (x) in ax temporarily
            sub ax,ball_x               ;subtract ball_x from ax
            cmp ax,ball_size            ;compare the result of the above with ball width
            jng draw_ball_horizontal    ;jump if x Not Greater than than ball_size

            mov cx,ball_x               ;change cx reg back to original x

            inc dx                      ;increment y value
            mov ax,dx                   ;move dx (y) in ax temporarily
            sub ax,ball_y               ;subtract ball_y into ax
            cmp ax,ball_size            ;compare the result of above with ball height
            jng draw_ball_horizontal    ;jump if y Not Greater than ball_size

        ret
    draw_ball endp
code ends

end
