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
    b.ne loop1

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

delay:
    mov x19, #1
    lsl x19, x19, 22
repeat:
    sub x19, x19, 1
    cbnz x19, repeat
    ret
    

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
    
    stp x1,x2,[sp,#-16]!
    stp x3,x4,[sp,#-16]!
    stp x5,x6,[sp,#-16]!
    stp x7,lr,[sp,#-16]!

    cmp x18, #1
    b.eq dibujo2

    // Dibuja un rectángulo (fondo)
    movz w1, 0xFFa0, lsl 16
	movk w1, 0x96b2, lsl 00 // Color fondo violetita
    mov x2, #0 
    mov x3, #0 
    mov x4, #SCREEN_WIDTH 
    mov x5, #SCREEN_HEIGHT 
    bl pintarRectangulo

    // Dibuja un círculo (pelo)
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #330
    mov x3, #88
    mov x6, #66
    bl pintarCirculo

    // Dibuja un rectángulo (pelo)
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #251 
    mov x3, #53 
    mov x4, #272 
    mov x5, #134 
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo) 
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #245 
    mov x3, #97 
    mov x4, #251 
    mov x5, #141 
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #383 
    mov x3, #47 
    mov x4, #395 
    mov x5, #146 
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #395 
    mov x3, #72
    mov x4, #401 
    mov x5, #122 
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #295 
    mov x3, #21
    mov x4, #364 
    mov x5, #28 
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #289 
    mov x3, #28
    mov x4, #376 
    mov x5, #34 
    bl pintarRectangulo

    // Dibuja un rectángulo (pelo)
    movz w1, 0xFF97, lsl 16
	movk w1, 0x5449, lsl 00 // Color pelo
    mov x2, #282 
    mov x3, #34
    mov x4, #383 
    mov x5, #47 
    bl pintarRectangulo

    // Dibuja un rectángulo (cara)
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #264 
    mov x3, #121 
    mov x4, #357 
    mov x5, #321 
    bl pintarRectangulo

    // Dibuja un rectángulo (cara)
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #276 
    mov x3, #103 
    mov x4, #357 
    mov x5, #121 
    bl pintarRectangulo

    // Dibuja un círculo (cara)
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #333 
    mov x3, #123
    mov x6, #47 
    bl pintarCirculo

    // Dibuja un círculo (oreja)
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #267 
    mov x3, #152
    mov x6, #23 
    bl pintarCirculo

    // Dibuja un rectángulo (cara)
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #357 
    mov x3, #102 
    mov x4, #382 
    mov x5, #184 
    bl pintarRectangulo

    // Dibuja un rectángulo (oreja 2)
    movz w1, 0xFFa1, lsl 16
	movk w1, 0x657e, lsl 00 // Color piel
    mov x2, #383 
    mov x3, #159 
    mov x4, #389 
    mov x5, #177 
    bl pintarRectangulo

    /*// Dibuja un triangulo (oreja 2)
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
    movz w1, 0xFF4B, lsl 16
    movk w1, 0x4930, lsl 00 // Color claro del saco
    mov x2, #482 
    mov x3, #296 
    mov x4, #507 
    mov x5, #SCREEN_HEIGHT 
    bl pintarRectangulo

    // Dibuja un rectángulo (saco brillo izquierdo)
    movz w1, 0xFF4B, lsl 16
    movk w1, 0x4930, lsl 00 // Color claro del saco
    mov x2, #139 
    mov x3, #300 
    mov x4, #263 
    mov x5, #340 
    bl pintarRectangulo

    /*// Dibuja un triangulo (saco hombrera izquierda)
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
    movz w1, 0xFF36, lsl 16
    movk w1, 0x351d, lsl 00 // Color oscuro del saco
    mov x2, #139 
    mov x3, #340 
    mov x4, #279 
    mov x5, #SCREEN_HEIGHT 
    bl pintarRectangulo

    // Dibuja un rectángulo (saco der)
    movz w1, 0xFF36, lsl 16
    movk w1, 0x351d, lsl 00 // Color oscuro del saco
    mov x2, #350 
    mov x3, #289 
    mov x4, #482 
    mov x5, #SCREEN_HEIGHT 
    bl pintarRectangulo

    // Dibuja un rectángulo (camisa brillo abajo)
    movz w1, 0xFFC4, lsl 16
    movk w1, 0xB9CA, lsl 00 // Color claro camisa
    mov x2, #276 
    mov x3, #384 
    mov x4, #283 
    mov x5, #SCREEN_HEIGHT 
    bl pintarRectangulo

    // Dibuja un rectángulo (camisa brillo arriba)
    movz w1, 0xFFC4, lsl 16
    movk w1, 0xB9CA, lsl 00 // Color claro camisa
    mov x2, #270 
    mov x3, #321 
    mov x4, #283 
    mov x5, #384 
    bl pintarRectangulo

    // Dibuja un rectángulo (camisa oscuro abajo)
    movz w1, 0xFF9d, lsl 16
    movk w1, 0x93aa, lsl 00 // Color oscuro camisa
    mov x2, #284 
    mov x3, #321 
    mov x4, #349 
    mov x5, #SCREEN_HEIGHT 
    bl pintarRectangulo

    // Dibuja un rectángulo (camisa cuello abajo)
    movz w1, 0xFFC4, lsl 16
    movk w1, 0xB9CA, lsl 00 // Color claro camisa
    mov x2, #257 
    mov x3, #316 
    mov x4, #270 
    mov x5, #321 
    bl pintarRectangulo

    // Dibuja un rectángulo (camisa cuello casi abajo)
    movz w1, 0xFFC4, lsl 16
    movk w1, 0xB9CA, lsl 00 // Color claro camisa
    mov x2, #245 
    mov x3, #290 
    mov x4, #270 
    mov x5, #315 
    bl pintarRectangulo

    // Dibuja un rectángulo (camisa cuello casi arriba)
    movz w1, 0xFFC4, lsl 16
    movk w1, 0xB9CA, lsl 00 // Color claro camisa
    mov x2, #239 
    mov x3, #259 
    mov x4, #270 
    mov x5, #290 
    bl pintarRectangulo

    // Dibuja un rectángulo (camisa cuello arriba izq-medio)
    movz w1, 0xFFC4, lsl 16
    movk w1, 0xB9CA, lsl 00 // Color claro camisa
    mov x2, #264 
    mov x3, #242 
    mov x4, #270 
    mov x5, #259 
    bl pintarRectangulo

    /*// Dibuja un triangulo (camisa cuello izq)
    movz w1, 0xFFC4, lsl 16
    movk w1, 0xB9CA, lsl 00 // Color claro camisa
    mov x2, #264 // Coordenada del primer vértice en x
    mov x3, #242 // Coordenada del primer vértice en y
    mov x4, #239 // Coordenada del segundo vértice en x
    mov x5, #259 // Coordenada del segundo vértice en y
    mov x0, #264 // Coordenada del tercer vértice en x
    mov x1, #259 // Coordenada del tercer vértice en y
    bl pintar_triangulo  // Llamada a pintar_triangulo
    */

    /*// Dibuja un triangulo (camisa cuello derecha under)
    movz w1, 0xFF3e, lsl 16
    movk w1, 0x3f53, lsl 00 // Color separador cuello
    mov x2, #258 // Coordenada del primer vértice en x
    mov x3, #240 // Coordenada del primer vértice en y
    mov x4, #294 // Coordenada del segundo vértice en x
    mov x5, #316 // Coordenada del segundo vértice en y
    mov x0, #344 // Coordenada del tercer vértice en x
    mov x1, #234 // Coordenada del tercer vértice en y
    bl pintar_triangulo  // Llamada a pintar_triangulo
    */

    /*// Dibuja un triangulo (camisa cuello derecha under)
    movz w1, 0xFFC4, lsl 16
    movk w1, 0xB9CA, lsl 00 // Color claro camisa
    mov x2, #258 // Coordenada del primer vértice en x
    mov x3, #240 // Coordenada del primer vértice en y
    mov x4, #301 // Coordenada del segundo vértice en x
    mov x5, #315 // Coordenada del segundo vértice en y
    mov x0, #344 // Coordenada del tercer vértice en x
    mov x1, #234 // Coordenada del tercer vértice en y
    bl pintar_triangulo  // Llamada a pintar_triangulo
    */

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #243 
    mov x3, #140 
    mov x4, #249 
    mov x5, #165 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #250 
    mov x3, #166 
    mov x4, #256 
    mov x5, #172 
    bl pintarRectangulo
    
// Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #257 
    mov x3, #173 
    mov x4, #263 
    mov x5, #179 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #264 
    mov x3, #180 
    mov x4, #270 
    mov x5, #186 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #271 
    mov x3, #192 
    mov x4, #277 
    mov x5, #208 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #278 
    mov x3, #209 
    mov x4, #284 
    mov x5, #215 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #285 
    mov x3, #216 
    mov x4, #291 
    mov x5, #222 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #293 
    mov x3, #223 
    mov x4, #299 
    mov x5, #229 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #300 
    mov x3, #230 
    mov x4, #312 
    mov x5, #236 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #313 
    mov x3, #237 
    mov x4, #330 
    mov x5, #243 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #331 
    mov x3, #230 
    mov x4, #337 
    mov x5, #236 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #338 
    mov x3, #223 
    mov x4, #350 
    mov x5, #229 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #351 
    mov x3, #216 
    mov x4, #357 
    mov x5, #222 
    bl pintarRectangulo

    // Dibuja un rectángulo (contorno cara)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #358 
    mov x3, #221 
    mov x4, #364 
    mov x5, #215 
    bl pintarRectangulo

    // Dibuja un rectángulo (ojo izq arriba)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #289
    mov x3, #115 
    mov x4, #314 
    mov x5, #121 
    bl pintarRectangulo

    // Dibuja un rectángulo (ojo izq medio)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #301
    mov x3, #121
    mov x4, #314
    mov x5, #127 
    bl pintarRectangulo

    // Dibuja un rectángulo (ojo izq abajo)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #289
    mov x3, #128
    mov x4, #307
    mov x5, #134 
    bl pintarRectangulo

    // Dibuja un rectángulo (ojo der medio)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #339
    mov x3, #121
    mov x4, #351
    mov x5, #134 
    bl pintarRectangulo

    // Dibuja un rectángulo (ojo der medio)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #351
    mov x3, #121
    mov x4, #364
    mov x5, #127
    bl pintarRectangulo

    // Dibuja un rectángulo (ojo der abajo)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #345
    mov x3, #135
    mov x4, #364
    mov x5, #140
    bl pintarRectangulo

    // Dibuja un rectángulo (boca arriba)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #301
    mov x3, #191
    mov x4, #339
    mov x5, #196
    bl pintarRectangulo

    // Dibuja un rectángulo (boca abajo)
    movz w1, 0xFF52, lsl 16
	movk w1, 0x0B09, lsl 00 // Color contorno piel
    mov x2, #305
    mov x3, #197
    mov x4, #335
    mov x5, #201
    bl pintarRectangulo

    // Dibuja un rectángulo (nariz abajo izq)
    movz w1, 0xFFc4, lsl 16
	movk w1, 0xb9ca, lsl 00 // Color claro piel
    mov x2, #314
    mov x3, #153
    mov x4, #332
    mov x5, #165
    bl pintarRectangulo

    // Dibuja un rectángulo (nariz abajo der)
    movz w1, 0xFFc4, lsl 16
	movk w1, 0xb9ca, lsl 00 // Color claro piel
    mov x2, #333
    mov x3, #161
    mov x4, #337
    mov x5, #165
    bl pintarRectangulo

    // Dibuja un rectángulo (nariz arriba der)
    movz w1, 0xFFc4, lsl 16
	movk w1, 0xb9ca, lsl 00 // Color claro piel
    mov x2, #326
    mov x3, #146
    mov x4, #332
    mov x5, #152
    bl pintarRectangulo

    // Dibuja un rectángulo (nariz arriba medio)
    movz w1, 0xFFc4, lsl 16
	movk w1, 0xb9ca, lsl 00 // Color claro piel
    mov x2, #320
    mov x3, #140
    mov x4, #326
    mov x5, #152
    bl pintarRectangulo

dibujo2:

    //fondo
    movz w1, 0xFF5F, lsl 16
	movk w1, 0x694D, lsl 00 // Color fondo verdecito
    mov x2, #0 
    mov x3, #0 
    mov x4, #SCREEN_WIDTH 
    mov x5, #SCREEN_HEIGHT 
    bl pintarRectangulo

    //rectangulo fondo mensaje
    movz w1, 0xFFa0, lsl 16
	movk w1, 0x96b2, lsl 00 // Color vioetita
    mov x2, #147
    mov x3, #131
    mov x4, #471
    mov x5, #256 
    bl pintarRectangulo

    //letras
    movz w1, 0xFF5F, lsl 16
	movk w1, 0x694D, lsl 00 // Color verdecito
    mov x2, #159
    mov x3, #131
    mov x4, #231
    mov x5, #244 
    bl pintarRectangulo

    movz w1, 0xFF5F, lsl 16
	movk w1, 0x694D, lsl 00 // Color verdecito
    mov x2, #244
    mov x3, #131
    mov x4, #250
    mov x5, #256 
    bl pintarRectangulo

    movz w1, 0xFF5F, lsl 16
	movk w1, 0x694D, lsl 00 // Color verdecito
    mov x2, #250
    mov x3, #131
    mov x4, #375
    mov x5, #185
    bl pintarRectangulo

    movz w1, 0xFF5F, lsl 16
	movk w1, 0x694D, lsl 00 // Color verdecito
    mov x2, #262
    mov x3, #185
    mov x4, #302
    mov x5, #244
    bl pintarRectangulo

    movz w1, 0xFF5F, lsl 16
	movk w1, 0x694D, lsl 00 // Color verdecito
    mov x2, #314
    mov x3, #185
    mov x4, #357
    mov x5, #244
    bl pintarRectangulo

    movz w1, 0xFF5F, lsl 16
	movk w1, 0x694D, lsl 00 // Color verdecito
    mov x2, #369
    mov x3, #131
    mov x4, #375
    mov x5, #260
    bl pintarRectangulo

    movz w1, 0xFF5F, lsl 16
	movk w1, 0x694D, lsl 00 // Color verdecito
    mov x2, #387
    mov x3, #131
    mov x4, #459
    mov x5, #244 
    bl pintarRectangulo


findibujo:
    ldp x7, lr, [sp], #16
    ldp x5, x6, [sp], #16
    ldp x3, x4, [sp], #16
    ldp x1, x2, [sp], #16
    br lr