.data
    menu:     .ascii  "\n Choose an operation by selecting a number (1-6)"
    	      .ascii  "\n1. Addition    2.Subtraction    3.Multiplication"
    	      .asciiz "\n    4. Division    5. Power    6. Exit\n"
    invalid:  .asciiz "\nNumber must be between 1 and 6!"
    input1:   .asciiz "\nGive the first number, or type 'M' to recall the last one: "
    input2:   .asciiz "\nGive the second number, or type 'M' to recall the last one: "
    result:   .asciiz "\n            The result is: "
    printSys: .ascii  "\nChoose a system to print by selecting a number (1-3)"
              .asciiz "\n    1. Decimal    2. Binary    3. Hexadecimal\n"
    input:    .space 10
    
.macro getInput
    li $t0, 0					# Clear temp registers
    li $t1, 0					
            
    la $a0, input1				# Print message
    jal printf
        
    la $a0, input				# Gives input address to $a0 
    li $a1, 10					# Max chars to read
    jal strGet					# Calls input function
    jal strParse				# Parse string to numbers
           
    addi $s0, $v1, 0				# Copies first number to $s0
       
    la $a0, input2				# Print message
    jal printf
        
    la $a0, input				# Gives input address to $a0
    li $a1, 10					# Max chars to read
    jal strGet					# Calls input function
    jal strParse				# Parse string to numbers
         
    addi $s1, $v1, 0				# Copies second number to $s1
      
    addi $a0, $s0, 0				# Restores first number from $s0 to $a0
    addi $a1, $s1, 0				# Restores second number from $s1 to $a1
.end_macro
    
.macro printResult				# Prints result to screen
    li $t5, 0					# Clears $t5
    addi $t5, $v1, 0				# Backups result to $t5
        
    la $a0, printSys				
    li $v0, 4
    syscall
            
    la $a0, input				# Gives input address to $a0
    li $a1, 3					# Max chars to read
    jal strGet					# Calls input function
    jal strParse				# Parse string to numbers
            
    la $a0, result				# Prints result message
    li $v0, 4
    syscall
            
    li $a0, 0					# Clears $a0
    addi $a0, $t5, 0				# Copies result to $a0
     
    beq $v1, 1, decimal				
    beq $v1, 2, binary
    beq $v1, 3, hex
            
    decimal:
        li $v0, 1
        syscall
        j printEnd
           
    binary:
        li $v0, 35
        syscall
        j printEnd
          
    hex:
        li $v0, 34
        syscall
               
    printEnd:
.end_macro
    
.text
    loopMenu:
        la $a0, menu
        jal printf
            
        la $a0, input				# Gives input address to $a0
        li $a1, 3				# Max chars to read
        jal strGet				# Calls input function
        jal strParse				# Parse string to numbers
               
        beq $v1, 1, additionBr
        beq $v1, 2, subtractionBr		
        beq $v1, 3, multiplicationBr		
        beq $v1, 4, divisionBr
        beq $v1, 5, powerBr
        beq $v1, 6, exit
              
        la $v0, invalid
        jal printf
        j loop
            
        additionBr:				# Addition Process
            getInput                   		# Calls getInput macro to get user input
            jal addition			# and passes variables to function.
            printResult				# Calls addition function
            j loopMenu				# Prints result to the screen.
                  
        subtractionBr:				# Subtraction Process
            getInput              		# Calls getInput macro to get user input
            jal subtraction			# and passes variables to function.
            printResult				# Calls subtraction function
            j loopMenu				# Prints result to the screen.
                
        multiplicationBr:			# Multiplication Process
            getInput                 		# Calls getInput macro to get user input
            jal multiplication			# and passes variables to function.
            printResult				# Calls multiplication function
            j loopMenu				# Prints result to the screen.
                  
        divisionBr:				# Division Process
            getInput                		# Calls getInput macro to get user input
            jal division			# and passes variables to function.
            printResult				# Calls division function
            j loopMenu				# Prints result to the screen.
                    
        powerBr:				# Power Process
            getInput                  		# Calls getInput macro to get user input
            jal power				# and passes variables to function.
            printResult				# Calls power function
            j loopMenu				# Prints result to the screen.
                
        exit:
            jal terminate
             
addition:
    add $v1, $a0, $a1
    add $s3, $v1, $zero				# Copies result to memory
    jr $ra
       
subtraction:
    sub $v1, $a0, $a1
    add $s3, $v1, $zero				# Copies result to memory
    jr $ra

multiplication:
    mul $v1, $a0, $a1
    add $s3, $v1, $zero				# Copies result to memory
    jr $ra

division:
    div $v1, $a0, $a1
    add $s3, $v1, $zero				# Copies result to memory
    jr $ra
        
power:
    li $v1, 0					# Clears $v1
    add $t0, $a1, 0				# Loads power into loop
    loop:
        beqz $a1, returnOne			# Checks if power is zero
        beqz $t0, endLoop			# Checks if loop is finished
        bne $v1, $zero, continue		# Checks if this is the first loop
        add $v1, $a0, $zero			# Adds base to result on first loop
        addi $t0, $t0, -1			# Reduces loop counter
        j loop
    continue:
        mul $v1, $v1, $a0			# Multiply base by itself
        addi $t0, $t0, -1			# Reduces loop counter
        j loop
    endLoop:
        add $s3, $v1, $zero			# Copies result to memory
        jr $ra
        returnOne:
        li $v1, 1
        add $s3, $v1, $zero			# Returns 1 if the power is zero
        jr $ra					# Copies result to memory
            
printf:
    li $v0, 4					# syscall to print string on screen
    syscall
    jr $ra
        
strGet:						# syscall to read string from 
    li $v0, 8					# user input
    syscall
    jr $ra
        
strParse:	# $t0 loop counter, $t1 ascii characters from string, 
		# $t2 true ascii number, $t3 multiples positions, $t4 end address
    li $v1, 0					# Clears $v1
    li $t0, 0					# Initializes loop counter
       
    add $t4, $a0, 0
    countLoop:
        lb $t1, 0($t4)				# Reads char from address
        beq $t1, $zero, done			# End of string
    
        addi $t4, $t4, 1			# Advance address
        j countLoop
	
    done:
        li $t0, 0				# Initializes loop counter
	li $t3, 1				# Sets multiples register
	
    loop2:
        lb $t1, -1($t4)				# Reads char from address
        beq $t1, 77, recallMem
        beq $t1, $zero, exitLoop		# End of string
	    
        ble $t1, 47, continue2			# If it's not in ascii int range
	    					# so less than 0 (47 in ascii)
        bge $t1, 58, continue2			# or greater than 9 (58 in ascii)
	    
        sub $t2, $t1, 48	   	# Subtracts 49 ascii code to get true integer
        mul $t2, $t2, $t3		# Multiplies to get position values (1s 10s etc)
        add $v1, $v1, $t2	    	# Adds result to $v1
        mul $t3, $t3, 10
     
	        
    continue2:
        addi $t4, $t4, -1			# Advance nexr string char-byte	        
        addi $t0, $t0, 1			# Advance counter
        j loop2
	        
    returnZero:
        li $v1, 0				# Returns zero
        j exitLoop
	        
    recallMem:
        addi $v1, $s3, 0			# Returns stored memory value
	        
    exitLoop:
        jr $ra
	        
terminate:
        li $v0, 10
        syscall    