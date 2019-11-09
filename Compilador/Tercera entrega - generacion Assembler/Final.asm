include macros2.asm 
include number.asm 
.MODEL LARGE
.386
.STACK 200h

MAXTEXTSIZE EQU 32

.DATA
NEW_LINE DB 0AH,0DH,'$'
CWprevio DW ?
abbaa dd ?
berta db "", '$'
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
_5 dd 5.0
_1 dd 1.0
@aux10 dd ?
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
fld _5
fstp a
etiqueta_8:
fld a
fld _1
fadd
fstp @aux10
fld @aux10
fstp a
DisplayFloat a,1
newLine

fld a
fld _10
fxch
fcomp
fstsw ax
sahf
JNE etiqueta_8

fld c
fld _10
fxch
fcomp
fstsw ax
sahf
JAE etiqueta_22

DisplayFloat c,1
newLine

etiqueta_22:
fld c
fld _10
fxch
fcomp
fstsw ax
sahf
JA etiqueta_28

DisplayString _hola,1
newLine

JMP etiqueta_29

etiqueta_28:
DisplayString _chau,1
newLine

etiqueta_29:
DisplayString _cadenuski,1
newLine

fld c
fld _10
fxch
fcomp
fstsw ax
sahf
JAE etiqueta_39

fld q
fld _20
fxch
fcomp
fstsw ax
sahf
JNA etiqueta_39

DisplayString _CONDICION_AND,1
newLine

etiqueta_39:
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
