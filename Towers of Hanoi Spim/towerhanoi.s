# Tower of Hanoi 
# MattFerreira, Wendy Ide
# March 7, 2016
#----------------------------------------------------------------

.data 
input:  .asciiz "\nEnter number of disks> "
movedisk: .asciiz "Move disk "
from: .asciiz " from rod "
to: .asciiz " to rod "
newline: .asciiz ".\n"
complete: .asciiz "\nComplete.\n"
negative: .asciiz "Please try agian with a valid number of disks (integers >= 0):\n\n"

.text
.globl main             #code assumes 3 rods

main: 
	li  $v0, 4
	la  $a0, input 
	syscall         #asks user for number of disks (n)
	li  $v0, 5   
	syscall          #reads in integer (n) from user    

	add   $a0, $zero, $v0      #puts n in $a0
	blt   $a0, $zero, n_neg    #branches to n_neg if user inputs a negative n
	addi  $a1, $zero, 0x41	   #ascii for A (start rod)
	addi  $a2, $zero, 0x43	   #ascii for C	(end rod) 
	addi  $a3, $zero, 0x42     #ascii for B (auxilerary rod)
	jal hanoi                  

exit:
	li  $v0, 4;       		
	la  $a0, complete    			
	syscall               #prints "Complete.\n"
	li  $v0, 10;			
	syscall               #syscall for terminate execution          

n_neg:
	li  $v0, 4
	la  $a0, negative
	syscall            #if n is negative, asks the user to try agian 
	jal main           #jal back to main

hanoi:
	addi  $sp, $sp, -20   #decrement the stack pointer by 20 
	sw    $ra, 16($sp)    #store $ra
	#store the saved regs
	sw    $s0, 12($sp)    
	sw    $s1, 8($sp)  
	sw    $s2, 4($sp)
	sw    $s3, 0($sp)

	beq	  $a0, $zero, n_zero  #if n=0, branch to n_zero, otherwise proceed

	addi  $sp, $sp, -16   #decrement the stack pointer by 16 
	#store the argument regs
	sw    $a0, 12($sp)    
	sw    $a1, 8($sp)
	sw    $a2, 4($sp)
	sw    $a3, 0($sp)

	add   $a0, $a0, -1	 #n = n-1
	#swap $a2 and $a3:
	add	  $t0, $zero, $a2;	#put $a2 into $t0	
	add	  $a2, $zero, $a3;	#put $a3 into $a2 
	add	  $a3, $zero, $t0;	#put $t0 into $a3	
	jal	  hanoi			    #recursion 
	
	#saved registers will get old argument registers
	lw    $s0, 0($sp)     
	lw    $s1, 4($sp)
	lw    $s2, 8($sp)
	lw    $s3, 12($sp)
	addi  $sp, $sp, 16   #increment the stack pointer by 16

	#process to print "Move disk $s3 from rod $s2 to rod $s1.\n"
	li  $v0, 4
	la  $a0, movedisk   
	syscall                  #prints "Move disk "
	li   $v0, 1
	add  $a0, $zero, $s3
	syscall                  #prints "$s3"
	li  $v0, 4
	la  $a0, from        
	syscall                  #prints " from rod "
	li   $v0, 11
	add  $a0, $zero, $s2
	syscall                  #prints "$s2"
	li  $v0, 4
	la  $a0, to          
	syscall                  #prints " to rod "
	li   $v0, 11
	add  $a0, $zero, $s1 
	syscall                  #prints "$s1"
	li  $v0, 4
	la  $a0, newline
	syscall                  #prints ".\n"

	addi  $a0, $s3, -1      # $s3 had $a0 so this command basically does n = n-1 
	add   $a1, $zero, $s0	#put $s0 into $a1
	add   $a2, $zero, $s1   #put $s1 into $a2
	add   $a3, $zero, $s2   #put s2 into $a3
	jal   hanoi;			#recursion

n_zero:
	#saved regs get old saved regs
	lw    $s3, 0($sp)   
	lw    $s2, 4($sp)
	lw    $s1, 8($sp)
	lw    $s0, 12($sp)
	lw	  $ra, 16($sp)   #get back old $ra
	addi  $sp, $sp, 20   #increment the stack pointer by 20
	jr    $ra            #jumps back to address in $ra that was just poped off stack 
	                     #(either jumps back to start of n_zero or back to the lw commands right before the prints)
