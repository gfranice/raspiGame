.equ SCREEN_WIDTH,   640
.equ SCREEN_HEIGHT,  480
.equ BITS_PER_PIXEL, 32

.equ GPIO_BASE,    0x3f200000
.equ GPIO_GPFSEL0, 0x00
.equ GPIO_GPLEV0,  0x34

.globl main

main:
    mov x20, x0 // Guarda la dirección base del framebuffer en x20
    mov x0, x20 // x0 = Dirección base del arreglo
    mov x18, #0 // Y Size
    
loop1:
    bl dibujo
    
    mov x17, x18
loop0:
    bl read_gpio_w
    cbz w27, loop1
    cmp x17, x18
    b.ne loop1 // otro loop

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

pintarRectangulo:
    stp x3, lr, [sp, #-16]!
    
loop_pintarRectangulo:
    cmp x3, x5
    b.gt fin_loop_pintarRectangulo
    bl pintarLineaHorizontal
    add x3, x3, #1
    b loop_pintarRectangulo
    
fin_loop_pintarRectangulo:
    ldp x3, lr, [sp], #16
    br lr