include macros2.asm 
include number.asm 
.MODEL LARGE
.386
.STACK 200h

MAXTEXTSIZE EQU 32

.DATA
NEW_LINE DB 0AH,0DH,'$'
CWprevio DW ?
@msj_entero db "Ingrese un valor entero", '$' 
@msj_real db "Ingrese un valor real", '$' 
abbaa dd ?
berta dd ?
b dd ?
var1 dd ?
a dd ?
c dd ?
d dd ?
e dd ?
cont dd ?
pepp db "", '$'
estoesunid dd ?
q dd ?
x db "", '$'
valorentero dd ?
_50 dd 50.0
_4 dd 4.0
_2 dd 2.0
@aux4 dd ?
_27_123456789 dd 27.123456789
_1 dd 1.0
_3 dd 3.0
_0 dd 0.0
@Filter1 dd ?
_FIN_FILTER_1 db "FIN_FILTER_1", '$'
_1_3323 dd 1.3323
_3_4555 dd 3.4555
_7_115 dd 7.115
_3_0 dd 3.0
_7_11 dd 7.11
@Filter2 dd ?
_FIN_FILTER_2 db "FIN_FILTER_2", '$'
@Filter3 dd ?
_FIN_FILTER_3 db "FIN_FILTER_3", '$'
_5 dd 5.0
@aux96 dd ?
_10 dd 10.0
_hola db "hola", '$'
_chau db "chau", '$'
_cadenuski db "cadenuski", '$'
_20 dd 20.0
_CONDICION_AND db "CONDICION_AND", '$'
_100 dd 100.0
_200 dd 200.0
_300 dd 300.0

.CODE

START:

MOV AX,@DATA
MOV DS, AX
FINIT

fld _50
fstp q
fld _4
fld _2
fadd
fstp @aux4
fld @aux4
fstp c
fld _27_123456789
fstp cont
DisplayFloat cont,1
newLine

DisplayString @msj_entero 
int 21h 
newLine 1
GetFloat abbaa 
DisplayFloat abbaa,1
newLine

DisplayString @msj_real 
int 21h 
newLine 1
GetFloat e 
DisplayFloat e,1
newLine

fld _1
fstp var1
fld _3
fstp c
fld _4
fstp d
fld var1
fld _3
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_24

fld var1
fstp @Filter1
JMP etiqueta_33

etiqueta_24:
fld c
fld _3
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_28

fld c
fstp @Filter1
JMP etiqueta_33

etiqueta_28:
fld d
fld _3
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_32

fld d
fstp @Filter1
JMP etiqueta_33

etiqueta_32:
fld _50
fstp @Filter1
etiqueta_33:
fld @Filter1
fstp abbaa
DisplayFloat abbaa,1
newLine

DisplayString _FIN_FILTER_1,1
newLine

fld _1_3323
fstp e
fld _3_4555
fstp b
fld _7_115
fstp cont
fld e
fld _3_0
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_51

fld e
fld _7_11
fxch
fcomp
fstsw ax
sahf
JA etiqueta_51

fld e
fstp @Filter2
JMP etiqueta_64

etiqueta_51:
fld b
fld _3_0
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_57

fld b
fld _7_11
fxch
fcomp
fstsw ax
sahf
JA etiqueta_57

fld b
fstp @Filter2
JMP etiqueta_64

etiqueta_57:
fld cont
fld _3_0
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_63

fld cont
fld _7_11
fxch
fcomp
fstsw ax
sahf
JA etiqueta_63

fld cont
fstp @Filter2
JMP etiqueta_64

etiqueta_63:
fld _50
fstp @Filter2
etiqueta_64:
fld @Filter2
fstp berta
DisplayFloat berta,1
newLine

DisplayString _FIN_FILTER_2,1
newLine

fld _1_3323
fstp e
fld _3_4555
fstp b
fld _7_115
fstp cont
fld e
fld _1_3323
fxch
fcomp
fstsw ax
sahf
JE etiqueta_79

fld e
fstp @Filter3
JMP etiqueta_88

etiqueta_79:
fld cont
fld _1_3323
fxch
fcomp
fstsw ax
sahf
JE etiqueta_83

fld cont
fstp @Filter3
JMP etiqueta_88

etiqueta_83:
fld b
fld _1_3323
fxch
fcomp
fstsw ax
sahf
JE etiqueta_87

fld b
fstp @Filter3
JMP etiqueta_88

etiqueta_87:
fld _50
fstp @Filter3
etiqueta_88:
fld @Filter3
fstp berta
DisplayFloat berta,1
newLine

DisplayString _FIN_FILTER_3,1
newLine

fld _5
fstp a
etiqueta_94:
fld a
fld _1
fadd
fstp @aux96
fld @aux96
fstp a
DisplayFloat a,1
newLine

fld a
fld _10
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_94

fld c
fld _10
fxch
fcomp
fstsw ax
sahf
JAE etiqueta_108

DisplayFloat c,1
newLine

etiqueta_108:
fld c
fld _10
fxch
fcomp
fstsw ax
sahf
JA etiqueta_114

DisplayString _hola,1
newLine

JMP etiqueta_115

etiqueta_114:
DisplayString _chau,1
newLine

etiqueta_115:
DisplayString _cadenuski,1
newLine

fld c
fld _10
fxch
fcomp
fstsw ax
sahf
JAE etiqueta_125

fld q
fld _20
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_125

DisplayString _CONDICION_AND,1
newLine

etiqueta_125:
fld _100
fstp q
fld _200
fstp c
fld _300
fstp d
DisplayFloat q,1
newLine

DisplayFloat c,1
newLine

DisplayFloat d,1
newLine


MOV AH, 1
INT 21h
MOV AX, 4C00h
INT 21h

END START
