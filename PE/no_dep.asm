; a PE executing code on the stack successfully with no DEP

; Ange Albertini, BSD LICENCE 2013

%include 'consts.inc'

IMAGEBASE equ 400000h
org IMAGEBASE
bits 32

SECTIONALIGN equ 1000h
FILEALIGN equ 200h

istruc IMAGE_DOS_HEADER
    at IMAGE_DOS_HEADER.e_magic,  db 'MZ'
    at IMAGE_DOS_HEADER.e_lfanew, dd NT_Headers - IMAGEBASE
iend

NT_Headers:
istruc IMAGE_NT_HEADERS
    at IMAGE_NT_HEADERS.Signature, db 'PE', 0, 0
iend
istruc IMAGE_FILE_HEADER
    at IMAGE_FILE_HEADER.Machine,              dw IMAGE_FILE_MACHINE_I386
    at IMAGE_FILE_HEADER.NumberOfSections,     dw NUMBEROFSECTIONS
    at IMAGE_FILE_HEADER.SizeOfOptionalHeader, dw SIZEOFOPTIONALHEADER
    at IMAGE_FILE_HEADER.Characteristics,      dw IMAGE_FILE_EXECUTABLE_IMAGE | IMAGE_FILE_32BIT_MACHINE
iend

OptionalHeader:
istruc IMAGE_OPTIONAL_HEADER32
    at IMAGE_OPTIONAL_HEADER32.Magic,                 dw IMAGE_NT_OPTIONAL_HDR32_MAGIC
    at IMAGE_OPTIONAL_HEADER32.AddressOfEntryPoint,   dd EntryPoint - IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.ImageBase,             dd IMAGEBASE
    at IMAGE_OPTIONAL_HEADER32.SectionAlignment,      dd SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.FileAlignment,         dd FILEALIGN
    at IMAGE_OPTIONAL_HEADER32.MajorSubsystemVersion, dw 4
    at IMAGE_OPTIONAL_HEADER32.SizeOfImage,           dd 2 * SECTIONALIGN
    at IMAGE_OPTIONAL_HEADER32.SizeOfHeaders,         dd SIZEOFHEADERS
    at IMAGE_OPTIONAL_HEADER32.Subsystem,             dw IMAGE_SUBSYSTEM_WINDOWS_CUI
    at IMAGE_OPTIONAL_HEADER32.DllCharacteristics,    dw 0 ; <== just making sure
    at IMAGE_OPTIONAL_HEADER32.NumberOfRvaAndSizes,   dd 16
iend

%include 'dd_imports.inc'

%include 'section_1fa.inc'

;*******************************************************************************

pop_eax_ equ 058h
retn_ equ 0c3h
nop_ equ 090h

EntryPoint:
    push Handler
    push dword [fs:0]
    mov [fs:0], esp
_
    push next
    push ((((retn_ << 8 | pop_eax_) << 8) | nop_) << 8) | nop_
    call esp
    int3

Handler
    push Msg
    call [__imp__printf]
    add esp, 1 * 4
_
next:
    push 0
    call [__imp__ExitProcess]
_c

Msg db " * executing code on the stack successfully with no DEP", 0ah, 0
_d

Import_Descriptor: ;************************************************************
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd kernel32.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd kernel32.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd kernel32.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
    at IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk, dd msvcrt.dll_hintnames - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.Name1,              dd msvcrt.dll - IMAGEBASE
    at IMAGE_IMPORT_DESCRIPTOR.FirstThunk,         dd msvcrt.dll_iat - IMAGEBASE
iend
istruc IMAGE_IMPORT_DESCRIPTOR
iend
_d

kernel32.dll_hintnames dd hnExitProcess - IMAGEBASE, 0
msvcrt.dll_hintnames   dd hnprintf - IMAGEBASE, 0
_d

hnExitProcess db 0,0, 'ExitProcess', 0
hnprintf      db 0,0, 'printf', 0
_d

kernel32.dll_iat:
__imp__ExitProcess dd hnExitProcess - IMAGEBASE
    dd 0

msvcrt.dll_iat:
__imp__printf dd hnprintf - IMAGEBASE
    dd 0
_d

kernel32.dll db 'kernel32.dll', 0
msvcrt.dll db 'msvcrt.dll', 0
_d

align FILEALIGN, db 0
