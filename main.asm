#include "p32mkxxxx.h"

section .data
    uart1_config:
        db 0x00
        db 0x00

    i2s_config:
        db 0x00
        db 0x00

section .bss
    rx_buffer db 0

section .text
    init_uart1:
        ; Calculate the U1BRG value for 115200 baud at 120MHz PBCLK
        li $t0, 120000000
        li $t1, 115200
        divu $t0, $t0, $t1
        subiu $t0, $t0, 1

        ; Configure UART1
        li $t1, U1MODE_RST
        la $t2, U1MODE
        sw $t2, 0($t1)

        li $t1, U1STA_RST
        la $t2, U1STA
        sw $t2, 0($t1)

        li $t1, U1BRG_RST
        la $t2, U1BRG
        sw $t2, 0($t1)

        li $t1, U1MODE_PDSEL_8N
        la $t2, U1MODE 
        sw $t2, 0($t1)

        li $t1, U1STA_UTXEN | U1STA_URXEN
        la $t2, U1STA
        sw $t2, 0($t1)

        li $t1, U1BRG_BRGHIGH
        la $t2, U1BRG
        sw $t2, 0($t1)

        li $t1, U1MODE_ON
        la $t2, U1MODE
        sw $t2, 0($t1)

        jr $ra

    init_i2s:
        mov eax, i2s_config
        mov al, [eax]
        la $t0, I2S1CON
        sw $t0, 0($eax)

        jr $ra

    uart1_receive_char:
        la $t0, U1STA
        lw $t1, 0($t0)
        andi $t1, $t1, 0x1
        beqz $t1, uart1_receive_char

        la $t0, U1RXREG
        lb $v0, 0($t0)

        jr $ra

    i2s_send_char:
        la $t0, I2S1STAT
        lw $t1, 0($t0)
        andi $t1, $t1, 0x8
        beqz $t1, i2s_send_char

        la $t0, I2S1TXREG
        sb $a0, 0($t0)

        jr $ra

    main:
        jal init_uart1
        jal init_i2s

    uart_to_i2s:
        jal uart1_receive_char
        jal i2s_send_char
        j uart_to_i2s
