include macros2.asm 
include number.asm 
.MODEL LARGE
.386
.STACK 200h

MAXTEXTSIZE EQU 32

.DATA
NEW_LINE DB 0AH,0DH,'$'
CWprevio DW ?
aaa dd 
berta db "", '$'
b dd 
var1 dd 
a dd 
c dd 
d dd 
e dd 
cont dd 
pepp db "", '$'
jdf dd 
q dd 
x db "", '$'
valorentero dd 
_Hola db "Hola", '$'
_10 dd 10.0
_20 dd 20.0
_5.5 dd 5.5
_1 dd 1.0
_12.3 dd 12.3
_11.5 dd 11.5
_3.8 dd 3.8
_37.5 dd 37.5
_5 dd 5.0
_5.0 dd 5.0
_33 dd 33.0
_35 dd 35.0
_0 dd 0.0
@Filter1 dd ?
@Filter2 dd ?
@Filter3 dd ?
@Filter4 dd ?

.CODE

START:

MOV AX, @DATA
MOV DS, AX
FINIT


MOV AH, 1
INT 21h
MOV AX, 4C00h
INT 21h

END START
