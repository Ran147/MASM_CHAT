INCLUDE Irvine32.inc

.data
;--------------Variables para la macro de escribir un txt----------------
    fileNamew    db "respuesta.txt", 0       ; Name of the file to write
    fileContent db "Success for mission!", 0    ; Text to write to the file
    bytesWritten dd ? 
    errMsgFileOpenw db "Error: Unable to open the file.", 0
    errMsgWriteFile db "Error: Unable to write to the file.", 0
    successMsg db "Mensaje enviado!", 0
    successMsg_usuarios db " ", 0
    ;--------------Variables para el encriptado y desencriptado-------------
    inputString db 256 DUP (?)
    encryptedString db 256 DUP (?)
    decryptedMessage db 1000 dup(?)  ; Buffer to store decrypted message
    encryptionKey   db 42  ; Example encryption key
    inputPromptremplazo db "Enviar: ", 0
    inputPrompt BYTE "Enter message or '/exit' to quit: ", 0
    exitCommand BYTE "/exit", 0
    exitMessage BYTE "Exiting application.", 0
;--------------Variables para la macro de leer txt----------------------
    fileName   db "ingreso.txt", 0

    buffer     db 1000 dup(?)  ; Buffer to store file contents
    bytesRead  dd ?
    errMsgFileOpen db "Error: Unable to open the file.", 0
    errMsgReadFile db "Error: Unable to read the file.", 0
;-------------Variables para la autenticacion----------------------------
    buffer_size         equ 128
    menuPrompt BYTE "Select an option:", 0
    option1 BYTE "1. Login", 0
    option2 BYTE "2. Sign In", 0
    choice WORD ?
    invalidChoiceMsg BYTE "Invalid choice!", 0
    loginMsg db "Has ingresado! ", 0
    signInMsg db "Has creado tu cuenta exitosamente! "
    registerN db "Nombres.txt", 0
    registerC db "Contrasenas.txt", 0
    ; User input variables
    userName db 50 dup(?)               ; Variable to hold the entered username
    userPassword        db 50 dup(?)               ; Variable to hold the entered password
    msg1 BYTE "Escriba su nombre: ", 0
;-----------Variables de la conversacion--------------------------------
    destinatario db 50 dup(?) 
    comando db "/exit", 0
    msgdestinatario db "Con quien deseas conversar? ", 0
    enviar db "Enviar: ", 0
    mensajito db 100 dup(?)
    usuario1 db "sender.txt", 0
    usuario2 db "receiver.txt", 0
    enviar1 db "Enviar: ", 0
    op1 db "CONTACTOS:",0Ah
        db "1.Randy",   0Ah
        db "2.Alisson", 0Ah
        db "3.Jennifer",0Ah
        db "4.Fabricio",0Ah
        db "          ", 0
;-----------Titulo-----------------------------
asciiArt db "  ___  ______  _____  _   _   ___ _____ ",0Ah
         db " / _ \ | ___ \/  __ \| | | | / _ \_   _|",0Ah
         db "/ /_\ \| |_/ /| /  \/| |_| |/ /_\ \| |  ",0Ah
         db "|  _  ||    / | |    |  _  ||  _  || |  ",0Ah
         db "| | | || |\ \ | \__/\| | | || | | || |  ",0Ah
         db "\_| |_/\_| \_| \____/\_| |_/\_| |_/\_/",0Ah
         db "                                      ",0  
    

.code
;La macro me escribe un archivo txt en el mismo directorio del proyecto
WRITE_FILE_MACRO MACRO fileName:REQ, fileContent:REQ, successMsg:REQ
    ; Open the file for writing
    invoke CreateFile, ADDR fileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    cmp eax, INVALID_HANDLE_VALUE
    ; If invalid handle, jump to error handling
    mov ebx, eax        ; Save the file handle in EBX register

    ; Write to the file
    invoke WriteFile, ebx, ADDR fileContent, SIZEOF fileContent - 1, ADDR bytesWritten, NULL
    test eax, eax
    

    ; Close the file
    invoke CloseHandle, ebx


ENDM

; Macro to read the contents of a text file into a buffer
; Assumes the file is located in the project directory
READ_FILE_MACRO MACRO fileName:REQ, buffer:REQ, bytesRead:REQ, errMsgFileOpen:REQ, errMsgReadFile:REQ
    ; Open the file for reading
    invoke CreateFile, ADDR fileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    cmp eax, INVALID_HANDLE_VALUE
    je file_open_error  ; If invalid handle, jump to error handling
    mov ebx, eax        ; Save the file handle in EBX register

    ; Read the file contents into the buffer
    invoke ReadFile, ebx, ADDR buffer, SIZEOF buffer, ADDR bytesRead, NULL
    test eax, eax
    jz read_error

    ; Close the file
    invoke CloseHandle, ebx  ; Use EBX register to close the file handle

    jmp end_program

file_open_error:
    mov edx, OFFSET errMsgFileOpen
    call WriteString
    jmp end_program

read_error:
    mov edx, OFFSET errMsgReadFile
    call WriteString
    jmp end_program
end_program:

ENDM

;EN ESTA MACRO SE VERIFICA SI EL INPUT ES EXIT
; Macro for XOR encryption
XOR_ENCRYPT MACRO input, output, key
    LOCAL encrypt_loop
    mov esi, OFFSET input          ; Point to the beginning of the input string
    mov edi, OFFSET output         ; Point to the beginning of the output string
    mov ecx, SIZEOF input          ; Set the loop counter to the length of the input string

encrypt_loop:
    mov al, [esi]                 ; Load the current character from input string
    xor al, key                   ; XOR the character with the encryption key
    mov [edi], al                 ; Store the encrypted character in output string
    inc esi                       ; Move to the next character in input string
    inc edi                       ; Move to the next character in output string
    loop encrypt_loop             ; Repeat until all characters are encrypted
ENDM


; Macro for XOR decryption
XOR_DECRYPT MACRO input, output, key, length
    LOCAL decrypt_loop
    mov esi, OFFSET input          ; Point to the beginning of the input string
    mov edi, OFFSET output         ; Point to the beginning of the output string
    mov ecx, length                ; Set the loop counter to the actual message length

decrypt_loop:
    test ecx, ecx                  ; Check if loop counter has reached 0
    jz end_decrypt                 ; If yes, jump to end_decrypt
    mov al, [esi]                  ; Load the current character from input string
    xor al, key                    ; XOR the character with the encryption key
    mov [edi], al                  ; Store the decrypted character in output string
    inc esi                        ; Move to the next character in input string
    inc edi                        ; Move to the next character in output string
    dec ecx                        ; Decrement loop counter
    jmp decrypt_loop               ; Continue loop
    
end_decrypt:
    mov byte ptr [edi], 0          ; Null-terminate the output string
ENDM
; Macro to perform the specified operations
ENCRYPT_WRITE_EXIT MACRO
   ; Display prompt for input
    mov edx, OFFSET inputPrompt
    call WriteString

    ; Read input string
    mov edx, OFFSET inputString
    mov ecx, SIZEOF inputString
    call ReadString

    ; Check if input is "/exit"
    mov esi, OFFSET inputString ; ESI points to the start of input
    mov edi, OFFSET exitCommand ; EDI points to the string "/exit"
    mov ecx, 5 ; Length of the string "/exit" including the null terminator
    repe cmpsb ; Repeat while equal comparison of byte [esi] with byte [edi], decrement ECX each time
    jz exit_program ; If ZF is set, strings are equal, jump to exitLabel

    ; Encrypt the input string
    XOR_ENCRYPT inputString, encryptedString, encryptionKey

    ; Write the encrypted string to a file
    WRITE_FILE_MACRO fileNamew, encryptedString, successMsg
ENDM
; Macro to read a text file, decrypt its contents, and print the decrypted message
READ_DECRYPT_PRINT MACRO
    ; Define local labels
    LOCAL open_file, read_file, decrypt_loop, print_message

    ; Open the file for reading
open_file:
    READ_FILE_MACRO fileName, buffer, bytesRead, errMsgFileOpen, errMsgReadFile

    ; Decrypt the content of the file
    mov esi, OFFSET buffer          ; Point to the beginning of the input buffer
    mov edi, OFFSET decryptedString; Point to the beginning of the decrypted string
    mov ecx, bytesRead              ; Set the loop counter to the number of bytes read

    decrypt_loop:
        cmp byte ptr [esi], 0       ; Check for end of buffer
        je end_decrypt_loop        ; If end of buffer reached, exit loop
        mov al, [esi]               ; Load the current character from input buffer
        xor al, encryptionKey       ; XOR the character with the encryption key
        mov [edi], al               ; Store the decrypted character in decrypted string
        inc esi                     ; Move to the next character in input buffer
        inc edi                     ; Move to the next character in decrypted string
        loop decrypt_loop          ; Repeat until all characters are decrypted
    end_decrypt_loop:

    ; Null-terminate the decrypted string
    mov byte ptr [edi], 0           ; Add null terminator at the end of the decrypted string

    ; Print the decrypted message
    print_message:
        mov edx, OFFSET decryptedString ; Point to the decrypted string
        call WriteString                ; Print the decrypted message

    
ENDM
DecryptAndPrintFile MACRO fileName:REQ, buffer:REQ, bytesRead:REQ, errMsgFileOpen:REQ, errMsgReadFile:REQ, decryptedMessage:REQ, encryptionKey:REQ
    ; Read the file
    READ_FILE_MACRO fileName, buffer, bytesRead, errMsgFileOpen, errMsgReadFile

    ; Decrypt the message
    XOR_DECRYPT buffer, decryptedMessage, encryptionKey, bytesRead

    ; Print the decrypted message
    mov edx, OFFSET decryptedMessage
    call WriteString

   
ENDM
; Macro to clear the console screen
CLEAR_SCREEN MACRO
    ; Call the ClearScreen function from Irvine32
    call    Clrscr
ENDM
SetCursorAndPrint MACRO row:REQ, column:REQ, string:REQ
    ; Set the cursor position to the specified row and column
    mov edx, row      ; Row
    mov ecx, column   ; Column
    call Gotoxy       ; Set cursor position

    ; Print the specified string at the cursor position
    mov edx, OFFSET string  ; Address of the string
    call WriteString        ; Print the string
ENDM


;---Lo que tengo que hacer es si o si trabajar con las macros que ya tengo en el original
;---Aqui voy a purificarlas y si es necesario cambiar el metodo de encryptacion
;----Con que escriba y lea ya comienzo pruebas de dos personas.
main PROC
    ; Initialize Irvine32
    ; This is not necessary if Irvine32.inc is properly included at the beginning of the program
    mov edx, offset asciiArt
    call WriteString
    call Crlf
    xor edx, edx

    mov edx, OFFSET menuPrompt
    call WriteString
    call Crlf

    mov edx, OFFSET option1
    call WriteString
    call Crlf

    mov edx, OFFSET option2
    call WriteString
    call Crlf

    ; Read user input
    call ReadInt
    mov choice, ax

    ; Process user choice
    cmp choice, 1
    je login_selected
    cmp choice, 2
    je signin_selected

    ; Invalid choice
    mov edx, OFFSET invalidChoiceMsg
    call WriteString
    jmp exit_program

login_selected: ; la logica del log in y sign in va ser lo ultimo que haga.
;EN ESTA PARTE PUEDO INMEDIATAMENTE PREGUNTAR POR USUARIO Y CONTRASEÑA
; PYTHON BUSCA Y ME DEVUELVE UN SI O NO SI ES SI PASA A CONVERSAR1 SI ES NO CIERRA EL PROGRAMA
    xor eax, eax
    mov edx, offset msg1
    call WriteString
    lea edx, userName  ; Load effective address of userName into edx
    mov ecx, 50        ; Maximum number of characters to read
    call ReadString    ; Read user input
    WRITE_FILE_MACRO usuario1, userName, successMsg_usuarios
    xor edx, edx
    xor ecx, ecx
    jmp conversar1

    

signin_selected:
    ; Your sign-in logic here
    mov edx, OFFSET signInMsg
    call WriteString
    jmp login_selected

conversar1:
    ;AQUI SE ENSEÑAN LOS USUARIOS
    ;Aqui iria el gui, este me pregunta el nombre del destinatario y este lo guardo.
    CLEAR_SCREEN
    mov edx, offset op1
    call WriteString
    xor edx, edx
    Call Crlf
    mov edx, offset msgdestinatario
    call WriteString
    mov edx, offset destinatario
    mov ecx, 50
    call ReadString
    CLEAR_SCREEN
    WRITE_FILE_MACRO usuario2, destinatario, successMsg_usuarios
    jmp conversar2

conversar2:
    SetCursorAndPrint 0, 0, destinatario
    xor edx, edx
    xor ecx, ecx
    call Crlf
    ;HACER UNA THREAD ACA
    DecryptAndPrintFile fileName, buffer, bytesRead, errMsgFileOpen, errMsgReadFile, decryptedMessage, encryptionKey
    call Crlf
    ENCRYPT_WRITE_EXIT
    ;Al parecer siempre lee de izquierda a derecha entonces siempre desencriptaria unicamente el primer mensaje
    ;Cuando de leer se trata
    ;Cuando se trata de escribir se podria decir que lo primero antes del primer asterisco es el ultimo mensaje
    ;Escrito entonces eso hay que arreglarlo desde PYTHON.
    
    
    ; ya puede escribir los nombres del sender y receiver en los txt respectivos, ya puede escribir un mensaje dado en un txt
    ; ya puede leer y desencriptar mensajes recibidos, falta conectarlo con python y probar.
    CLEAR_SCREEN

    jmp conversar2


    ;El nombre del destinatario aparece arriba a la izquierda y ahora me deja escribir mensajes
    ;Los mensajes se encriptan y se escriben en el txt de respuesta
    ;Los mensajes que recibo yo son leidos del txt de ingreso, se desencriptan y se enseñan.


exit_program:
    CLEAR_SCREEN
    call Crlf
    ; Handle the exit operation here
    ; For example, you could display a message or clean up resources
    mov edx, OFFSET exitMessage
    call WriteString
    ; Include any additional exit procedures here
    exit
 
main ENDP

END main






