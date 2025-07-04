.equ SCREEN_WIDTH,   640
.equ SCREEN_HEIGHT,  480
.equ BITS_PER_PIXEL, 32

.equ GPIO_BASE,    0x3f200000
.equ GPIO_GPFSEL0, 0x00
.equ GPIO_GPLEV0,  0x34

.globl main

main:
  mov x20, x0
  mov x18, #0

  bl dibujo  
InfLoop:
  b InfLoop

.macro SET_COLOR reg, high, low
  movz \reg, \high, lsl #16
  movk \reg, \low, lsl #0
.endm

dibujo:
  stp x29, x30, [sp, #-16]!
  mov x29, sp

  //  Fondo
  SET_COLOR w1, 0xFFa0, 0x96b2
  mov x2, #0
  mov x3, #0
  mov x4, #SCREEN_WIDTH
  mov x5, #SCREEN_HEIGHT
  bl pintarRectangulo

  //  Pelo
  SET_COLOR w1, 0xFF97, 0x5449

  //  Circulo inicial
  mov x2, #330
  mov x3, #88
  mov x6, #66
  bl pintarCirculo

  //  rectangulos secundarios
  mov x2, #251
  mov x3, #53
  mov x4, #272
  mov x5, #134
  bl pintarRectangulo

  mov x2, #245
  mov x3, #97
  mov x4, #251
  mov x5, #141
  bl pintarRectangulo

  mov x2, #383
  mov x3, #47
  mov x4, #395
  mov x5, #146
  bl pintarRectangulo

  mov x2, #395
  mov x3, #72
  mov x4, #401
  mov x5, #122
  bl pintarRectangulo

  mov x2, #295
  mov x3, #21
  mov x4, #364
  mov x5, #28
  bl pintarRectangulo

  mov x2, #289
  mov x3, #28
  mov x4, #376
  mov x5, #34
  bl pintarRectangulo

  mov x2, #282
  mov x3, #34
  mov x4, #383
  mov x5, #47
  bl pintarRectangulo

  //  Cara
  SET_COLOR w1, 0xFFa1, 0x657e
  mov x2, #264
  mov x3, #121
  mov x4, #357
  mov x5, #321
  bl pintarRectangulo

  mov x2, #276
  mov x3, #103
  mov x4, #357
  mov x5, #121
  bl pintarRectangulo

  mov x2, #333
  mov x3, #123
  mov x6, #47
  bl pintarCirculo

  mov x2, #357
  mov x3, #102
  mov x4, #382
  mov x5, #184
  bl pintarRectangulo

  //  Orejas
  mov x2, #267
  mov x3, #152
  mov x6, #23
  bl pintarCirculo

  mov x2, #383
  mov x3, #159
  mov x4, #389
  mov x5, #177
  bl pintarRectangulo

  //  contorno cara
  SET_COLOR w1, 0xFF52, 0x0B09
  mov x2, #243
  mov x3, #140
  mov x4, #249
  mov x5, #165
  bl pintarRectangulo

  mov x2, #250
  mov x3, #166
  mov x4, #256
  mov x5, #172
  bl pintarRectangulo

  mov x2, #257
  mov x3, #173
  mov x4, #263
  mov x5, #179
  bl pintarRectangulo

  mov x2, #264
  mov x3, #180
  mov x4, #270
  mov x5, #186
  bl pintarRectangulo

  mov x2, #271
  mov x3, #192
  mov x4, #277
  mov x5, #208
  bl pintarRectangulo

  mov x2, #278
  mov x3, #209
  mov x4, #284
  mov x5, #215
  bl pintarRectangulo

  mov x2, #285
  mov x3, #216
  mov x4, #291
  mov x5, #222
  bl pintarRectangulo

  mov x2, #293
  mov x3, #223
  mov x4, #299
  mov x5, #229
  bl pintarRectangulo

  mov x2, #300
  mov x3, #230
  mov x4, #312
  mov x5, #236
  bl pintarRectangulo

  mov x2, #313
  mov x3, #237
  mov x4, #330
  mov x5, #243
  bl pintarRectangulo

  mov x2, #331
  mov x3, #230
  mov x4, #337
  mov x5, #236
  bl pintarRectangulo

  mov x2, #338
  mov x3, #223
  mov x4, #350
  mov x5, #229
  bl pintarRectangulo

  mov x2, #351
  mov x3, #216
  mov x4, #357
  mov x5, #222
  bl pintarRectangulo

  mov x2, #358
  mov x3, #221
  mov x4, #364
  mov x5, #215
  bl pintarRectangulo

  //  Eyes
  mov x2, #289
  mov x3, #115
  mov x4, #314
  mov x5, #121
  bl pintarRectangulo

  mov x2, #301
  mov x3, #121
  mov x4, #314
  mov x5, #127
  bl pintarRectangulo

  mov x2, #289
  mov x3, #128
  mov x4, #307
  mov x5, #134
  bl pintarRectangulo

  mov x2, #339
  mov x3, #121
  mov x4, #351
  mov x5, #134
  bl pintarRectangulo

  mov x2, #351
  mov x3, #121
  mov x4, #364
  mov x5, #127
  bl pintarRectangulo

  mov x2, #345
  mov x3, #135
  mov x4, #364
  mov x5, #140
  bl pintarRectangulo

  //  Mouth
  mov x2, #301
  mov x3, #191
  mov x4, #339
  mov x5, #196
  bl pintarRectangulo

  mov x2, #305
  mov x3, #197
  mov x4, #335
  mov x5, #201
  bl pintarRectangulo

  //  Nariz
  SET_COLOR w1, 0xFFB8, 0x7CA0
  
  mov x2, #314
  mov x3, #153
  mov x4, #332
  mov x5, #165
  bl pintarRectangulo

  mov x2, #333
  mov x3, #161
  mov x4, #337
  mov x5, #165
  bl pintarRectangulo

  mov x2, #326
  mov x3, #146
  mov x4, #332
  mov x5, #152
  bl pintarRectangulo

  mov x2, #320
  mov x3, #140
  mov x4, #326
  mov x5, #152
  bl pintarRectangulo

  //  Saco
  //  Parte iluminada
  SET_COLOR w1, 0xFF4B, 0x4930

  //  derecha
  mov x2, #482
  mov x3, #296
  mov x4, #507
  mov x5, #SCREEN_HEIGHT
  bl pintarRectangulo

  //  izquierda
  mov x2, #139
  mov x3, #300
  mov x4, #263
  mov x5, #340
  bl pintarRectangulo

  //  Sombra
  SET_COLOR w1, 0xFF36, 0x351d

  //  izquierda
  mov x2, #139
  mov x3, #340
  mov x4, #279
  mov x5, #SCREEN_HEIGHT
  bl pintarRectangulo

  //  derecha
  mov x2, #350
  mov x3, #289
  mov x4, #482
  mov x5, #SCREEN_HEIGHT
  bl pintarRectangulo

  //  Camisa
  //  Parte iluminada
  SET_COLOR w1, 0xFFC4, 0xB9CA

  //  bajo
  mov x2, #276
  mov x3, #384
  mov x4, #283
  mov x5, #SCREEN_HEIGHT
  bl pintarRectangulo

  //  arriba
  mov x2, #270
  mov x3, #321
  mov x4, #283
  mov x5, #384
  bl pintarRectangulo

  // cuello
  mov x2, #257
  mov x3, #316
  mov x4, #270
  mov x5, #321
  bl pintarRectangulo

  mov x2, #245
  mov x3, #290
  mov x4, #270
  mov x5, #315
  bl pintarRectangulo

  mov x2, #239
  mov x3, #259
  mov x4, #270
  mov x5, #290
  bl pintarRectangulo

  mov x2, #264
  mov x3, #242
  mov x4, #270
  mov x5, #259
  bl pintarRectangulo

  //  sombra
  SET_COLOR w1, 0xFF9d, 0x93aa
  mov x2, #284
  mov x3, #321
  mov x4, #349
  mov x5, #SCREEN_HEIGHT
  bl pintarRectangulo
  
  ldp x29, x30, [sp], #16
  ret
