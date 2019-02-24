TITLE Programming Assignment #3     (Program03.asm)

; Author: Jordan Hamilton
; Last Modified: 2/9/2019
; OSU email address: hamiltj2@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 3                Due Date: 2/10/2019
; Description: This program will introduce the program and programmer, get two numbers from the user,
; perform addition, subtraction, multiplication and division on the numbers, and then display the results.

INCLUDE Irvine32.inc

NAMELENGTH          EQU       48
LOWERLIMIT          EQU       -100
UPPERLIMIT          EQU       -1

.data

intro               BYTE      "Programming assignment #3 by Jordan Hamilton",0
nameGreeting        BYTE      "Hey there, ",0
nameIn              BYTE      NAMELENGTH+1 DUP (?)
namePrompt          BYTE      "What's your name? ",0

instruction1        BYTE      "Please enter negative integers between -1 and -100, inclusive.",0
instruction2        BYTE      "When you're finished, enter a non-negative number to exit.",0
instruction3        BYTE      "We'll find the sum and rounded average of the negative numbers.",0

numberPrompt        BYTE      "Enter an integer: ",0
noNumbersMsg        BYTE      "You didn't enter any valid integers!",0
retryMsg            BYTE      "You'll need to enter an integer greater than -101. Enter an integer greater than -1 to quit.",0

sumMsg              BYTE      "The sum of your entered numbers is ",0
avgMsg              BYTE      "The rounded average of your entered numbers is ",0

outro               BYTE      "Take care, ",0

username            DWORD     ?
numberCount         DWORD     0
remainder           DWORD     0
sum                 DWORD     0
average             DWORD     0

.code

main PROC

; Display an introduction

     ; Introduce the program (and programmer)
     mov      edx, OFFSET intro
     call     WriteString
     call     Crlf
     
     ; Prompt the user to enter a name, then store it in nameIn
     mov      edx, OFFSET namePrompt
     call     WriteString
     mov      edx, OFFSET nameIn
     mov      ecx, NAMELENGTH
     call     ReadString

     ; Greet the user
     mov      edx, OFFSET nameGreeting
     call     WriteString
     mov      edx, OFFSET nameIn
     call     WriteString
     call     Crlf

     ; Display valid number entry instructions and expected output
     mov      edx, OFFSET instruction1
     call     WriteString
     call     Crlf
     
     mov      edx, OFFSET instruction2
     call     WriteString
     call     Crlf

     mov      edx, OFFSET instruction3
     call     WriteString
     call     Crlf

     ; Prompt the user to enter a number, then call ReadInt to get input
     ; If the overflow flag is set after reading the integer, prompt for input again
     getNumber:
          mov      edx, OFFSET numberPrompt
          call     WriteString
          call     ReadInt
          jo       getNumber
          
          ; If the number entered is greater than -1, begin to calculate the average
          ; Don't include this number in the sum and don't increment the number of entered integers
          cmp      eax, UPPERLIMIT
          jg       endInput

          ; If the number entered was less than -1, make sure it's greater than or equal to -100
          ; If the range is correct, proceed to include this number in our calculations
          ; Otherwise, display an error message and prompt for valid input again
          cmp      eax, LOWERLIMIT
          jge      validInput
          mov      edx, OFFSET retryMsg
          call     WriteString
          call     Crlf
          jmp      getNumber
          
     ; Add 1 to the count of number of integers that were in the correct range, then add the entered number to the sum variable
     ; Repeat the prompt to enter an integer
     validInput:
          inc      numberCount
          add      sum, eax
          jmp      getNumber

     ; Check if any numbers were entered, then begin calculating if the numberCount variable is greater than 0
     ; Display an error message and jump to the goodbye message if no valid numbers were entered for calculation
     ; This avoids dividing by zero when calculating the average
     endInput:
          cmp      numberCount, 0
          jg       calcAverage
          mov      edx, OFFSET noNumbersMsg
          call     WriteString
          jmp      exitMsg

     ; Perform signed integer division with the sum divided by the numberCount to get the average and the remainder after division
     calcAverage:
          mov      eax, sum
          cdq
          mov      ebx, numberCount
          idiv     numberCount
          mov      average, eax
          mov      remainder, edx
          
          ; If the remainder after calculating the average is not 0, then round the average
          ; Otherwise, display the results to the user
          cmp      remainder, 0
          je       outputResults

     round:
          ; Divide the numbers we counted by 2 so we can compare half of the previous operation's divisor with the remainder of that operation 
          mov      eax, numberCount
          mov      ebx, 2
          mov      edx, 0
          div      ebx
          
          ; Reverse the sign of the result, since the sign of the remainder when averaging negative numbers was negative 
          neg      eax
          
          ; If the remainder from averaging is less than half of the number count, then its absolute value is greater than one half of the divisor ( > 0.5 )
          ; Skip to displaying results if the remainder is less than or equal to half of the divisor ( <= 0.5 )
          cmp      remainder, eax
          jge      outputResults
          
          ; Round by subtracting one from the average if we determined the remainder equates to more than one half the divisor
          dec      average

     ; Output sum and rounded average results
     outputResults:
          mov     edx, OFFSET sumMsg
          call    WriteString
          mov     eax, sum
          call    WriteInt
          call    Crlf

          mov     edx, OFFSET avgMsg
          call    WriteString
          mov     eax, average
          call    WriteInt
          call    Crlf

; Say goodbye
     exitMsg:
          ; Display the exit message
          mov      edx, OFFSET outro
          call     Crlf
          call     WriteString
          mov      edx, OFFSET nameIn
          call     WriteString

     ; Exit to the operating system
	INVOKE ExitProcess,0
	
main ENDP

END main
