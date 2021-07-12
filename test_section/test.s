main:
	li	s2, 10
	li	s3, 20
	li	s4, 5
	add	s1, s2, s3
	add	s5, s1, zero
	mul	s1, s2, s4
	add	s1, s1, s5
	add	s6, s1, zero
	mul	s1, s3, s5
	div	s1, s1, s4
	add	s5, s1, zero
	add	s1, s2, s3
	add	s1, s1, s4
	add	s1, s1, s5
	add	s1, s1, s6
	add	s7, s1, zero
	div	s1, s2, s4
	add	s3, s1, zero
