# NOT THE COMPLETE SOLUTION, but a blueprint of a pwntools script
from pwn import *

# Delivering payload into local binary
binary = context.binary = ELF('./escape1_static')
p = process(binary.path) 

# Craft Payload
## buffer = INSERT BUFFER HERE
## padding = INSERT PADDING HERE
## return_address = INSERT CORRECT RETURN ADDRESS HERE
## payload = buffer + padding + p64(return_address)  

# Deliver Payload
p.sendline(payload)
pause()

p.interactive()