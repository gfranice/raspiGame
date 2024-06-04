.equ SCREEN_WIDTH,   640
.equ SCREEN_HEIGHT,  480
.equ BITS_PER_PIXEL, 32

.equ GPIO_BASE,    0x3f200000
.equ GPIO_GPFSEL0, 0x00
.equ GPIO_GPLEV0,  0x34

.globl main

main:
    mov x20, x0 // Guarda la dirección base del framebuffer en x20
    
loop1:

loop0:


InfLoop:
    b InfLoop

pintarPixel:
    cmp x2, SCREEN_WIDTH // Veo si el x es valido
    b.hs fin_pintarPixel
    cmp x3, SCREEN_HEIGHT // Veo si el y es valido
    b.hs fin_pintarPixel
    mov x9, SCREEN_WIDTH
    mul x9, x9, x3
    add x9, x9, x2
    str w1, [x0, x9, lsl #2]

fin_pintarPixel:
    br lr

pintarLineaVertical:
    stp x3, lr, [sp, #-16]!
    
loop_pintarLineaVertical:
    cmp x3, x4
    b.gt fin_loop_pintarLineaVertical
    bl pintarPixel
    add x3, x3, #1
    b loop_pintarLineaVertical

fin_loop_pintarLineaVertical:
    ldp x3, lr, [sp], #16
    br lr

pintarLineaHorizontal:
    stp x2, lr, [sp, #-16]!
    
loop_pintarLineaHorizontal:
    cmp x2, x4
    b.gt fin_loop_pintarLineaHorizontal
    bl pintarPixel
    add x2, x2, #1
    b loop_pintarLineaHorizontal

fin_loop_pintarLineaHorizontal:
    ldp x2, lr, [sp], #16
    br lr

pintarCirculo:
    sub sp, sp, #8 // Guardo el puntero de retorno en el stack
    stur lr, [sp]

    mov x15, x2 // Guardo en x15 la coordenada del centro en x
    mov x16, x3 // Guardo en x16 la coordenada del centro en y
    add x10, x2, x6 // Guardo en x10 la posición final en x
    add x11, x3, x6 // Guardo en x11 la posición final en y
    mul x12, x6, x6 // x12 = r^2 // para comparaciones en el loop
    sub x2, x2, x6 // Pongo en x2 la posición inicial en x

loop0_pintarCirculo: // loop para avanzar en x
    cmp x2, x10
    b.gt fin_loop0_pintarCirculo
    sub x3, x11, x6
    sub x3, x3, x6 // Pongo en x3 la posición inicial en y

loop1_pintarCirculo: // loop para avanzar en y
    cmp x3, x11
    b.gt fin_loop1_pintarCirculo // Veo si tengo que pintar el pixel actual
    sub x13, x2, x15 // x13 = distancia en x desde el pixel actual al centro
    smull x13, w13, w13 // x13 = w13 * w13
    sub x14, x3, x16 // x14 = distancia en y desde el pixel actual al centro
    smaddl x13, w14, w14, x13 // x13 = x14*x14 + x13
    cmp x13, x12
    b.gt fi_pintarCirculo
    bl pintarPixel // Pinto el pixel actual

fi_pintarCirculo:
    add x3, x3, #1
    b loop1_pintarCirculo

fin_loop1_pintarCirculo:
    add x2, x2, #1
    b loop0_pintarCirculo

fin_loop0_pintarCirculo:
    mov x2, x15 // Restauro en x2 la coordenada del centro en x
    mov x3, x16 // Restauro en x3 la coordenada del centro en y
    ldur lr, [sp] // Recupero el puntero de retorno del stack
    add sp, sp, #8
    br lr // return

read_gpio_w:
    add x27, xzr, xzr
    mov x26, GPIO_BASE // direccion del GPIO a x26
    str wzr, [x26, GPIO_GPFSEL0] // GPIO como solo lectura
    ldr w27, [x26, GPIO_GPLEV0]
    and w27, w27, 0b00000010
    cbz w27, endfun

    cmp x18, #1
    b.eq skipW
    mov x18, #1
    b endfun
skipW:
    mov x18, #0
    
endfun:
    ret
    
dibujo:

    // Dibuja el fondo
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF97, lsl 16
	movk w1, 0x6bc9, lsl 00 // Color fondo violetita
    mov x2, #0 // Coordenada inicial en x
    mov x3, #0 // Coordenada inicial en y
    mov x4, #SCREEN_WIDTH // Coordenada final en x
    mov x5, #SCREEN_HEIGHT // Coordenada final en y
    bl pintarRectangulo

findibujo:
    ldp x7, lr, [sp], #16
    ldp x5, x6, [sp], #16
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    br lr