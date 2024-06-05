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

    // Dibuja un rectángulo (fondo)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa0, lsl 16
	movk w1, 0x96b2, lsl 00 // Color fondo violetita
    mov x2, #0 // Coordenada inicial en x
    mov x3, #0 // Coordenada inicial en y
    mov x4, #SCREEN_WIDTH // Coordenada final en x
    mov x5, #SCREEN_HEIGHT // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un círculo (pelo)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #330 // Coordenada del centro en x
    mov x3, #88 // Coordenada del centro en y
    mov x6, #66 // Radio
    bl pintarCirculo

    // Dibuja un rectángulo (pelo)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #251 // Coordenada inicial en x
    mov x3, #53 // Coordenada inicial en y
    mov x4, #272 // Coordenada final en x
    mov x5, #134 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #245 // Coordenada inicial en x
    mov x3, #97 // Coordenada inicial en y
    mov x4, #251 // Coordenada final en x
    mov x5, #141 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #383 // Coordenada inicial en x
    mov x3, #47 // Coordenada inicial en y
    mov x4, #395 // Coordenada final en x
    mov x5, #146 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #395 // Coordenada inicial en x
    mov x3, #72// Coordenada inicial en y
    mov x4, #401 // Coordenada final en x
    mov x5, #122 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #295 // Coordenada inicial en x
    mov x3, #21// Coordenada inicial en y
    mov x4, #364 // Coordenada final en x
    mov x5, #28 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #289 // Coordenada inicial en x
    mov x3, #28// Coordenada inicial en y
    mov x4, #376 // Coordenada final en x
    mov x5, #34 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #282 // Coordenada inicial en x
    mov x3, #34// Coordenada inicial en y
    mov x4, #383 // Coordenada final en x
    mov x5, #47 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (cara)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #264 // Coordenada inicial en x
    mov x3, #121 // Coordenada inicial en y
    mov x4, #364 // Coordenada final en x
    mov x5, #357 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (cara)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #276 // Coordenada inicial en x
    mov x3, #103 // Coordenada inicial en y
    mov x4, #357 // Coordenada final en x
    mov x5, #121 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un círculo (cara)
    //PROBAR ALTURA PARA CEJAS
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #333 // Coordenada del centro en x
    mov x3, #123 // Coordenada del centro en y
    mov x6, #47 // Radio
    bl pintarCirculo

    // Dibuja un círculo (oreja)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #267 // Coordenada del centro en x
    mov x3, #152 // Coordenada del centro en y
    mov x6, #23 // Radio
    bl pintarCirculo

    // Dibuja un rectángulo (cara)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #357 // Coordenada inicial en x
    mov x3, #102 // Coordenada inicial en y
    mov x4, #382 // Coordenada final en x
    mov x5, #184 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (ceja izq)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0xFFFF, lsl 00 // Color piel
    mov x2, #289  // Coordenada inicial en x
    mov x3, #115 // Coordenada inicial en y
    mov x4, #313 // Coordenada final en x
    mov x5, #121 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (ceja izq)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0xFFFF, lsl 00 // Color piel
    mov x2, #301 // Coordenada inicial en x
    mov x3, #122 // Coordenada inicial en y
    mov x4, #313 // Coordenada final en x
    mov x5, #128 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (ceja izq)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0xFFFF, lsl 00 // Color piel
    mov x2, #289 // Coordenada inicial en x
    mov x3, #129 // Coordenada inicial en y
    mov x4, #307 // Coordenada final en x
    mov x5, #135 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (ceja der)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0xFFFF, lsl 00 // Color piel
    mov x2, #338  // Coordenada inicial en x
    mov x3, #121 // Coordenada inicial en y
    mov x4, #362 // Coordenada final en x
    mov x5, #127 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (ceja der)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0xFFFF, lsl 00 // Color piel
    mov x2, #338 // Coordenada inicial en x
    mov x3, #128 // Coordenada inicial en y
    mov x4, #350 // Coordenada final en x
    mov x5, #134 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (ceja der)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0xFFFF, lsl 00 // Color piel
    mov x2, #344 // Coordenada inicial en x
    mov x3, #135 // Coordenada inicial en y
    mov x4, #362 // Coordenada final en x
    mov x5, #141 // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (oreja 2)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #383 // Coordenada inicial en x
    mov x3, #159 // Coordenada inicial en y
    mov x4, #389 // Coordenada final en x
    mov x5, #177 // Coordenada final en y
    bl pintarRectangulo

    /*// Dibuja un triangulo (oreja 2)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF0000, lsl 16
    movk w1, 0x00FF, lsl 00 // Color piel
    mov x2, #357 // Coordenada del primer vértice en x
    mov x3, #183 // Coordenada del primer vértice en y
    mov x4, #382 // Coordenada del segundo vértice en x
    mov x5, #183 // Coordenada del segundo vértice en y
    mov x0, #357 // Coordenada del tercer vértice en x
    mov x1, #209 // Coordenada del tercer vértice en y
    bl pintar_triangulo  // Llamada a pintar_triangulo
    */

    /*// Dibuja un triangulo (saco brillo hombrera izquierda)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF4B, lsl 16
    movk w1, 0x4930, lsl 00 // Color claro del saco
    mov x2, #263 // Coordenada del primer vértice en x
    mov x3, #242 // Coordenada del primer vértice en y
    mov x4, #139 // Coordenada del segundo vértice en x
    mov x5, #300 // Coordenada del segundo vértice en y
    mov x0, #363 // Coordenada del tercer vértice en x
    mov x1, #139 // Coordenada del tercer vértice en y
    bl pintar_triangulo  // Llamada a pintar_triangulo
    */

    /*// Dibuja un triangulo (saco brillo hombrera derecha)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF4B, lsl 16
    movk w1, 0x4930, lsl 00 // Color claro del saco
    mov x2, #357 // Coordenada del primer vértice en x
    mov x3, #234 // Coordenada del primer vértice en y
    mov x4, #357 // Coordenada del segundo vértice en x
    mov x5, #296 // Coordenada del segundo vértice en y
    mov x0, #507 // Coordenada del tercer vértice en x
    mov x1, #296 // Coordenada del tercer vértice en y
    bl pintar_triangulo  // Llamada a pintar_triangulo
    */

    // Dibuja un rectángulo (saco brillo derecha)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF4B, lsl 16
    movk w1, 0x4930, lsl 00 // Color claro del saco
    mov x2, #482 // Coordenada inicial en x
    mov x3, #296 // Coordenada inicial en y
    mov x4, #507 // Coordenada final en x
    mov x5, #SCREEN_HEIGHT // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (saco brillo izquierdo)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF4B, lsl 16
    movk w1, 0x4930, lsl 00 // Color claro del saco
    mov x2, #139 // Coordenada inicial en x
    mov x3, #300 // Coordenada inicial en y
    mov x4, #263 // Coordenada final en x
    mov x5, #340 // Coordenada final en y
    bl pintarRectangulo

    /*// Dibuja un triangulo (saco hombrera izquierda)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF36, lsl 16
    movk w1, 0x351d, lsl 00 // Color oscuro del saco
    mov x2, #270 // Coordenada del primer vértice en x
    mov x3, #246 // Coordenada del primer vértice en y
    mov x4, #139 // Coordenada del segundo vértice en x
    mov x5, #340 // Coordenada del segundo vértice en y
    mov x0, #270 // Coordenada del tercer vértice en x
    mov x1, #340 // Coordenada del tercer vértice en y
    bl pintar_triangulo  // Llamada a pintar_triangulo
    */

    /*// Dibuja un triangulo (saco hombrera derecha)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF36, lsl 16
    movk w1, 0x351d, lsl 00 // Color oscuro del saco
    mov x2, #390 // Coordenada del primer vértice en x
    mov x3, #289 // Coordenada del primer vértice en y
    mov x4, #139 // Coordenada del segundo vértice en x
    mov x5, #389 // Coordenada del segundo vértice en y
    mov x0, #270 // Coordenada del tercer vértice en x
    mov x1, #389 // Coordenada del tercer vértice en y
    bl pintar_triangulo  // Llamada a pintar_triangulo
    */

    /*// Dibuja un triangulo (saco cuello derecha)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF36, lsl 16
    movk w1, 0x351d, lsl 00 // Color oscuro del saco
    mov x2, #390 // Coordenada del primer vértice en x
    mov x3, #245 // Coordenada del primer vértice en y
    mov x4, #350 // Coordenada del segundo vértice en x
    mov x5, #289 // Coordenada del segundo vértice en y
    mov x0, #270 // Coordenada del tercer vértice en x
    mov x1, #289 // Coordenada del tercer vértice en y
    bl pintar_triangulo  // Llamada a pintar_triangulo
    */

    // Dibuja un rectángulo (saco izq)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF36, lsl 16
    movk w1, 0x351d, lsl 00 // Color oscuro del saco
    mov x2, #139 // Coordenada inicial en x
    mov x3, #340 // Coordenada inicial en y
    mov x4, #279 // Coordenada final en x
    mov x5, #SCREEN_HEIGHT // Coordenada final en y
    bl pintarRectangulo

    // Dibuja un rectángulo (saco der)
    mov x0, x20 // Dirección base del arreglo
    movz w1, 0xFF36, lsl 16
    movk w1, 0x351d, lsl 00 // Color oscuro del saco
    mov x2, #350 // Coordenada inicial en x
    mov x3, #289 // Coordenada inicial en y
    mov x4, #482 // Coordenada finalal en x
    mov x3, #289 // Coordenada inicial en y
    mov x4, #482 // Coordenada final en x
    mov x5, #SCREEN_HEIGHT // Coordenada final en y
    bl pintarRectangulo

findibujo:
    ldp x7, lr, [sp], #16
    ldp x5, x6, [sp], #16
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    br lr
