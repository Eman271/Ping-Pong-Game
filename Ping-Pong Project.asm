; 2 PLAYER PONG GAME 
; EMAN FATIMA   24L-3008
; FATIMA KAMRAN 24L-3027

[org 0x0100]

jmp start

oldisr: dd 0
oldtimer: dd 0
p1_y: dw 10
p2_y: dw 10
ball_x: dw 40
ball_y: dw 12
ball_dx: dw 1
ball_dy: dw 1
p1_score: dw 0
p2_score: dw 0
game_over: dw 0
paddle_height: dw 5
tickcount: dw 0
speed_delay: dw 2
winning_score: dw 5
need_redraw: dw 1

s_1: db '  ____   ___  _   _  ____ ', 0
s_2: db ' |  _ \ / _ \| \ | |/ ___|', 0
s_3: db ' | |_) | | | |  \| | |  _ ', 0
s_4: db ' |  __/| |_| | |\  | |_| |', 0
s_5: db ' |_|    \___/|_| \_|\____|', 0

s_6: db '    ||         ||    ', 0
s_7: db '    ||    O    ||    ', 0
s_8: db '    ||         ||    ', 0

p1_1: db '  ____  _  __        _____ _   _  ____  ', 0
p1_2: db ' |  _ \/ | \ \      / /_ _| \ | / ___| ', 0
p1_3: db ' | |_) | |  \ \ /\ / / | ||  \| \___ \ ', 0
p1_4: db ' |  __/| |   \ V  V /  | || |\  |___) |', 0
p1_5: db ' |_|   |_|    \_/\_/  |___|_| \_|____/ ', 0

p2_1: db '  ____  ____   __        _____ _   _  ____  ', 0
p2_2: db ' |  _ \|_ __ \ \ \      / /_ _| \ | / ___| ', 0
p2_3: db ' | |_) | __) /  \ \ /\ / / | ||  \| \___ \ ', 0
p2_4: db ' |  __// __ /    \ V  V /  | || |\  |___) |', 0
p2_5: db ' |_|   |_____|    \_/\_/  |___|_| \_|____/ ', 0

; high pitch sound ( when ball touches paddle )
hit:
    push ax
    push cx
    
    mov al, 0xB6        
    out 0x43, al       
    
    mov ax, 1000       
    out 0x42, al      
    mov al, ah
    out 0x42, al       
    
    in al, 0x61
    or al, 0x03
    out 0x61, al
    
    mov cx, 0x3000
	
hit_delay:
    loop hit_delay
    
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    pop cx
    pop ax
    ret

; low pitch sound ( when ball misses paddles )
miss:
    push ax
    push cx
    
    mov al, 0xB6
    out 0x43, al
    
    mov ax, 2000       
    out 0x42, al
    mov al, ah
    out 0x42, al

    in al, 0x61
    or al, 0x03
    out 0x61, al
    
    mov cx, 0x8000
	
miss_delay:
    loop miss_delay
    
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    pop cx
    pop ax
    ret
	
kbisr: 
    push ax
    push bx
    in al, 0x60
    
    cmp al, 0x11
    jne check_s
    mov bx, [cs:p1_y]
    cmp bx, 1
    jle exit
    dec word [cs:p1_y]
    mov word [cs:need_redraw], 1
    jmp exit
    
check_s: 
    cmp al, 0x1f
    jne check_up
    mov bx, [cs:p1_y]
    add bx, [cs:paddle_height]
    cmp bx, 23
    jge exit
    inc word [cs:p1_y]
    mov word [cs:need_redraw], 1
    jmp exit
    
check_up: 
    cmp al, 0x48
    jne check_down
    mov bx, [cs:p2_y]
    cmp bx, 1
    jle exit
    dec word [cs:p2_y]
    mov word [cs:need_redraw], 1
    jmp exit
    
check_down: 
    cmp al, 0x50
    jne nomatch
    mov bx, [cs:p2_y]
    add bx, [cs:paddle_height]
    cmp bx, 23
    jge exit
    inc word [cs:p2_y]
    mov word [cs:need_redraw], 1
    jmp exit
    
nomatch: 
    pop bx
    pop ax
    jmp far [cs:oldisr]
    
exit: 
    mov al, 0x20
    out 0x20, al
    pop bx
    pop ax
    iret
	
timer: 
    push ax
    
    inc word [cs:tickcount]
    mov ax, [cs:tickcount]
    push bx
    mov bx, [cs:speed_delay]
    xor dx, dx
    div bx
    pop bx
    cmp dx, 0
    jne near skipall
    
    push bx
    push cx
    push dx
    push ds
    push cs
    pop ds
    
    cmp word [game_over], 1
    je near skipgame
    
    mov ax, [ball_x]
    add ax, [ball_dx]
    mov [ball_x], ax
    
    mov ax, [ball_y]
    add ax, [ball_dy]
    mov [ball_y], ax
    
    mov word [need_redraw], 1
    
    mov ax, [ball_y]
    cmp ax, 1
    jg check_bottom
    mov word [ball_dy], 1
    mov word [ball_y], 1
    jmp check_paddles
    
check_bottom:
    cmp ax, 23
    jl check_paddles
    mov word [ball_dy], -1
    mov word [ball_y], 23
    
check_paddles:
    mov ax, [ball_x]
    cmp ax, 1
    jg check_left_paddle
    inc word [p2_score]
    call miss
    call reset_ball
    mov word [ball_dx], 1
    mov word [need_redraw], 1
    mov ax, [p2_score]
    cmp ax, [winning_score]
    jge near set_game_over
    jmp skipgame
    
check_left_paddle:
    mov ax, [ball_x]
    cmp ax, 3
    jne check_right_edge
    
    mov ax, [ball_y]
    mov bx, [p1_y]
    cmp ax, bx
    jl check_right_edge
    add bx, [paddle_height]
    cmp ax, bx
    jge check_right_edge
    mov word [ball_dx], 1
    mov word [ball_x], 4
    call hit
    jmp skipgame
    
check_right_edge:
    mov ax, [ball_x]
    cmp ax, 78
    jl check_right_paddle
    inc word [p1_score]
    call miss
    call reset_ball
    mov word [ball_dx], -1
    mov word [need_redraw], 1
    mov ax, [p1_score]
    cmp ax, [winning_score]
    jge set_game_over
    jmp skipgame
    
check_right_paddle:
    mov ax, [ball_x]
    cmp ax, 76
    jne skipgame
    
    mov ax, [ball_y]
    mov bx, [p2_y]
    cmp ax, bx
    jl skipgame
    add bx, [paddle_height]
    cmp ax, bx
    jge skipgame
    mov word [ball_dx], -1
    mov word [ball_x], 75
    call hit
    jmp skipgame

set_game_over:
    mov word [game_over], 1
    mov word [need_redraw], 1

skipgame:
    pop ds
    pop dx
    pop cx
    pop bx

skipall:
    mov al, 0x20
    out 0x20, al
    pop ax
    iret
	
clrscr: 
    push es
    push ax
    push di
    push cx
    
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x0720
    mov cx, 2000
    cld
    rep stosw
    
    pop cx
    pop di
    pop ax
    pop es
    ret

draw_border:
    push es
    push ax
    push di
    push cx
    
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    mov cx, 80
    mov ax, 0x0f23
top_loop:
    mov [es:di], ax
    add di, 2
    loop top_loop
    
    mov di, 24 * 160
    mov cx, 80
bot_loop:
    mov [es:di], ax
    add di, 2
    loop bot_loop
    
    mov cx, 23
    mov di, 160
    mov ax, 0x0f7c
mid_loop:
    mov [es:di+80], ax
    add di, 160
    loop mid_loop
    
    pop cx
    pop di
    pop ax
    pop es
    ret

draw_paddle:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push di
    
    mov ax, 0xb800
    mov es, ax
    
    mov ax, [bp+8]
    mov bx, 160
    mul bx
    mov di, ax
    
    mov ax, [bp+6]
    shl ax, 1
    add di, ax
    
    mov ax, [bp+4]
    shl ax, 8
    or ax, 0xdb
    
    mov cx, [paddle_height]
	
paddle_loop:
    mov [es:di], ax
    add di, 160
    loop paddle_loop
    
    pop di
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 6

draw_ball:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push di
    
    mov ax, 0xb800
    mov es, ax
    
    mov ax, [bp+6]
    mov bx, 160
    mul bx
    mov di, ax
    
    mov ax, [bp+4]
    shl ax, 1
    add di, ax
    
    mov ax, 0x0adb
    mov [es:di], ax
    
    pop di
    pop bx
    pop ax
    pop es
    pop bp
    ret 4

p_score:
    push es
    push ax
    push bx
    push di
    
    mov ax, 0xb800
    mov es, ax
    
    mov di, 0
    mov ax, 0x0e50
    mov [es:di], ax
    add di, 2
    mov ax, 0x0e31
    mov [es:di], ax
    add di, 2
    mov ax, 0x0e3a
    mov [es:di], ax
    add di, 2
    mov ax, 0x0e20
    mov [es:di], ax
    add di, 2
    
    mov ax, [p1_score]
    cmp ax, 10
    jl p1_digit
    push ax
    mov bl, 10
    xor dx, dx
    div bl
    add al, 0x30
    mov ah, 0x0e
    mov [es:di], ax
    add di, 2
    mov al, dl
    add al, 0x30
    mov ah, 0x0e
    mov [es:di], ax
    add di, 2
    pop ax
    jmp p1_done
p1_digit:
    add al, 0x30
    mov ah, 0x0e
    mov [es:di], ax
    add di, 2
	
p1_done:
    
    mov ax, 0x0e20
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
    
    mov ax, 0x0e50
    mov [es:di], ax
    add di, 2
    mov ax, 0x0e32
    mov [es:di], ax
    add di, 2
    mov ax, 0x0e3a
    mov [es:di], ax
    add di, 2
    mov ax, 0x0e20
    mov [es:di], ax
    add di, 2
    
    mov ax, [p2_score]
    cmp ax, 10
    jl p2_digit
    push ax
    mov bl, 10
    xor dx, dx
    div bl
    add al, 0x30
    mov ah, 0x0e
    mov [es:di], ax
    add di, 2
    mov al, dl
    add al, 0x30
    mov ah, 0x0e
    mov [es:di], ax
    add di, 2
    pop ax
    jmp p2_done
p2_digit:
    add al, 0x30
    mov ah, 0x0e
    mov [es:di], ax
    add di, 2
p2_done:
    
    mov cx, 5
    mov ax, 0x0e20
clear_rest:
    mov [es:di], ax
    add di, 2
    loop clear_rest
    
    pop di
    pop bx
    pop ax
    pop es
    ret

reset_ball:
    push ax
    mov word [ball_x], 40
    mov word [ball_y], 12
    mov word [ball_dx], 1
    mov word [ball_dy], 1
    pop ax
    ret

show_game_over:
    push es
    push ax
    push di
    push si
    
    mov ax, 0xb800
    mov es, ax

    mov di, 5*160 + 68
    mov ax, 0x8c47 
    mov [es:di], ax
    add di, 2
    mov ax, 0x8c41 
    mov [es:di], ax
    add di, 2
    mov ax, 0x8c4d
    mov [es:di], ax
    add di, 2
    mov ax, 0x8c45 
    mov [es:di], ax
    add di, 2
    mov ax, 0x8c20 
    mov [es:di], ax
    add di, 2
    mov ax, 0x8c4f 
    mov [es:di], ax
    add di, 2
    mov ax, 0x8c56 
    mov [es:di], ax
    add di, 2
    mov ax, 0x8c45
    mov [es:di], ax
    add di, 2
    mov ax, 0x8c52
    mov [es:di], ax
    
    mov ax, [p1_score]
    cmp ax, [p2_score]
    jl p2_wins
    
    mov di, 9*160 + 40
    mov si, p1_1
    mov ah, 0x8e
    call p_str
    
    mov di, 10*160 + 40
    mov si, p1_2
    mov ah, 0x8e
    call p_str
    
    mov di, 11*160 + 40
    mov si, p1_3
    mov ah, 0x8e
    call p_str
    
    mov di, 12*160 + 40
    mov si, p1_4
    mov ah, 0x8e
    call p_str
    
    mov di, 13*160 + 40
    mov si, p1_5
    mov ah, 0x8e
    call p_str
    jmp show_restart
    
p2_wins:
   
    mov di, 9*160 + 38
    mov si, p2_1
    mov ah, 0x8b
    call p_str
    
    mov di, 10*160 + 38
    mov si, p2_2
    mov ah, 0x8b
    call p_str
    
    mov di, 11*160 + 38
    mov si, p2_3
    mov ah, 0x8b
    call p_str
    
    mov di, 12*160 + 38
    mov si, p2_4
    mov ah, 0x8b
    call p_str
    
    mov di, 13*160 + 38
    mov si, p2_5
    mov ah, 0x8b
    call p_str
    
show_restart:
    
    mov di, 18*160 + 50
    mov ax, 0x0f52
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f65
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f73
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f74
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f61
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f72
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f74
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f20
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f2d
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f20
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f52
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f20
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f45
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f78
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f69
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f74
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f20
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f2d
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f20
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f45
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f53
    mov [es:di], ax
    add di, 2
    mov ax, 0x0f43
    mov [es:di], ax
    
    pop si
    pop di
    pop ax
    pop es
    ret
show_instructions:
    push es
    push ax
    push di
    push si
    
    call clrscr
    
    mov ax, 0xb800
    mov es, ax
    
    mov di, 3*160 + 54
    mov si, s_1
    mov ah, 0x0e
    call p_str
    
    mov di, 4*160 + 54
    mov si, s_2
    mov ah, 0x0e
    call p_str
    
    mov di, 5*160 + 54
    mov si, s_3
    mov ah, 0x0e
    call p_str
    
    mov di, 6*160 + 54
    mov si, s_4
    mov ah, 0x0e
    call p_str
    
    mov di, 7*160 + 54
    mov si, s_5
    mov ah, 0x0e
    call p_str
    
    mov di, 10*160 + 60
    mov si, s_6
    mov ah, 0x0c
    call p_str
    
    mov di, 11*160 + 60
    mov si, s_7
    mov ah, 0x0a
    call p_str
    
    mov di, 12*160 + 60
    mov si, s_8
    mov ah, 0x0b
    call p_str
    
    mov di, 15*160 + 48
    mov si, msg1
    mov ah, 0x0f
    call p_str
    
    mov di, 16*160 + 30
    mov si, msg2
    mov ah, 0x0f
    call p_str
    
    mov di, 18*160 + 50
    mov si, msg3
    mov ah, 0x0f
    call p_str
    
    mov di, 20*160 + 48
    mov si, msg4a
    mov ah, 0x0f
    call p_str_np
    
    mov si, msg4b
    mov ah, 0x8c
    call p_str_np
    
    mov si, msg4c
    mov ah, 0x0f
    call p_str
    
    pop si
    pop di
    pop ax
    pop es
    ret

p_str_np:
    push ax
    push bx
    mov bh, ah
print_loop_no_pop:
    lodsb
    cmp al, 0
    je print_done_no_pop
    mov ah, bh
    stosw
    jmp print_loop_no_pop
print_done_no_pop:
    pop bx
    pop ax
    ret

p_str:
    push ax
    push bx
    push di
    mov bh, ah
print_loop_colored:
    lodsb
    cmp al, 0
    je print_done_colored
    mov ah, bh
    stosw
    jmp print_loop_colored
print_done_colored:
    pop di
    pop bx
    pop ax
    ret
	
msg1: db 'Player 1: W (up), S (down)', 0
msg2: db 'Player 2: Up Arrow (up), Down Arrow (down)', 0
msg3: db 'First to score 5 points wins', 0
msg4a: db 'Press ', 0
msg4b: db 'SPACE-BAR', 0
msg4c: db ' when ready', 0

start:
    call show_instructions
    
wait_for_space:
    mov ah, 0x00
    int 0x16
    cmp al, ' '
    jne wait_for_space
    
    xor ax, ax
    mov es, ax
    
    mov ax, [es:9*4]
    mov [oldisr], ax
    mov ax, [es:9*4+2]
    mov [oldisr+2], ax
    
    mov ax, [es:8*4]
    mov [oldtimer], ax
    mov ax, [es:8*4+2]
    mov [oldtimer+2], ax
    
    cli
    mov word [es:9*4], kbisr
    mov [es:9*4+2], cs
    
    mov word [es:8*4], timer
    mov [es:8*4+2], cs
    sti
    
    call clrscr

game_loop:
    cmp word [need_redraw], 0
    je skip_draw
    
    call clrscr
    call draw_border
    call p_score
    
    push word [p1_y]
    push word 2
    push word 0x04
    call draw_paddle
    
    push word [p2_y]
    push word 77
    push word 0x03
    call draw_paddle
    
    push word [ball_y]
    push word [ball_x]
    call draw_ball
    
    mov word [need_redraw], 0
    
skip_draw:
    cmp word [game_over], 1
    je end_game
    
    mov cx, 0x01ff
delay_loop:
    loop delay_loop
    
    jmp game_loop

end_game:
    call clrscr
    call show_game_over

wait_key:
    mov ah, 0x01
    int 0x16
    jz wait_key
    
    mov ah, 0x00
    int 0x16
    
    cmp al, 'r'
    je restart
    cmp al, 'R'
    je restart
    cmp ah, 0x01
    je exit_game
    jmp wait_key

restart:
    mov word [p1_score], 0
    mov word [p2_score], 0
    mov word [game_over], 0
    mov word [p1_y], 10
    mov word [p2_y], 10
    mov word [need_redraw], 1
    call reset_ball
    jmp game_loop

exit_game:
    xor ax, ax
    mov es, ax
    cli
    mov ax, [oldisr]
    mov [es:9*4], ax
    mov ax, [oldisr+2]
    mov [es:9*4+2], ax
    mov ax, [oldtimer]
    mov [es:8*4], ax
    mov ax, [oldtimer+2]
    mov [es:8*4+2], ax
    sti
    
    call clrscr
    mov ax, 0x4c00
    int 0x21