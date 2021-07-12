
test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000010078 <main>:
   10078:	00a00913          	li	s2,10
   1007c:	01400993          	li	s3,20
   10080:	00500a13          	li	s4,5
   10084:	013904b3          	add	s1,s2,s3
   10088:	00048ab3          	add	s5,s1,zero
   1008c:	034904b3          	mul	s1,s2,s4
   10090:	015484b3          	add	s1,s1,s5
   10094:	00048b33          	add	s6,s1,zero
   10098:	035984b3          	mul	s1,s3,s5
   1009c:	0344c4b3          	div	s1,s1,s4
   100a0:	00048ab3          	add	s5,s1,zero
   100a4:	013904b3          	add	s1,s2,s3
   100a8:	014484b3          	add	s1,s1,s4
   100ac:	015484b3          	add	s1,s1,s5
   100b0:	016484b3          	add	s1,s1,s6
   100b4:	00048bb3          	add	s7,s1,zero
   100b8:	034944b3          	div	s1,s2,s4
   100bc:	000489b3          	add	s3,s1,zero
