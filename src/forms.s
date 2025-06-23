// forms.s - funciones de dibujo
.equ SCREEN_WIDTH,   640
.equ SCREEN_HEIGHT,  480
.equ BITS_PER_PIXEL, 32

.globl pintarPixel
.globl pintarLineaVertical
.globl pintarLineaHorizontal
.globl pintarRectangulo
.globl pintarCirculo

pintarPixel:
  cmp x2, #SCREEN_WIDTH
  b.hs fin_pintarPixel
  cmp x3, #SCREEN_HEIGHT
  b.hs fin_pintarPixel
  
  // addr = base + (y * width + x) * 4
  mov x9, #SCREEN_WIDTH
  madd x9, x3, x9, x2      // x9 = y * width + x
  str w1, [x20, x9, lsl #2]

fin_pintarPixel:
  ret

pintarLineaVertical:
  stp x29, x30, [sp, #-16]!
  mov x29, sp
  cmp x3, x4
  b.gt fin_pintarLineaVertical

loop_pintarLineaVertical:
  bl pintarPixel
  add x3, x3, #1
  cmp x3, x4
  b.le loop_pintarLineaVertical

fin_pintarLineaVertical:
  ldp x29, x30, [sp], #16
  ret

pintarLineaHorizontal:
  stp x29, x30, [sp, #-16]!
  mov x29, sp
  
  cmp x2, x4
  b.gt fin_pintarLineaHorizontal

loop_pintarLineaHorizontal:
  bl pintarPixel
  add x2, x2, #1
  cmp x2, x4
  b.le loop_pintarLineaHorizontal

fin_pintarLineaHorizontal:
  ldp x29, x30, [sp], #16
  ret

pintarRectangulo:
  stp x29, x30, [sp, #-16]!
  stp x2, x4, [sp, #-16]!
  mov x29, sp  
  cmp x3, x5
  b.gt fin_pintarRectangulo

loop_pintarRectangulo:
  ldp x2, x4, [sp]
  bl pintarLineaHorizontal
  add x3, x3, #1
  cmp x3, x5
  b.le loop_pintarRectangulo

fin_pintarRectangulo:
  ldp x2, x4, [sp], #16
  ldp x29, x30, [sp], #16
  ret

pintarCirculo:
  stp x29, x30, [sp, #-16]!
  stp x15, x16, [sp, #-16]!
  stp x10, x11, [sp, #-16]!
  mov x29, sp  
  mov x15, x2     //  centro_x
  mov x16, x3     //  centro_y
  sub x10, x2, x6 //  min_x = centro_x - radio
  add x11, x2, x6 //  max_x = centro_x + radio
  sub x12, x3, x6 //  min_y = centro_y - radio
  add x13, x3, x6 //  max_y = centro_y + radio
  mul x14, x6, x6 //  radio al cuadrado
  mov x2, x10     //  x = min_x

loop_x_circle:
  cmp x2, x11
  b.gt fin_circle
  mov x3, x12     //  current_y = min_y

loop_y_circle:
  cmp x3, x13
  b.gt next_x_circle
  //  distancia = (x-cx)² + (y-cy)²
  sub x7, x2, x15       //  dx = x - centro_x
  sub x8, x3, x16       //  dy = y - centro_y
  mul x7, x7, x7        //  dx²
  madd x7, x8, x8, x7   //  dx² + dy²
  cmp x7, x14           //  Comp con radio²
  b.gt skip_pixel
  bl pintarPixel

skip_pixel:
  add x3, x3, #1
  b loop_y_circle

next_x_circle:
  add x2, x2, #1
  b loop_x_circle

fin_circle:
  mov x2, x15   //  recuperar coordinadas del centro
  mov x3, x16
  ldp x10, x11, [sp], #16
  ldp x15, x16, [sp], #16
  ldp x29, x30, [sp], #16
  ret
