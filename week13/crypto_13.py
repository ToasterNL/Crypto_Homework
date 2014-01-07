n = 110545695839248001
#n = 53098980256925153592047
a0 = 1
b0 = 1
c = 1

import fractions

a0 = (a0**2 + c) % n
b0 = (((b0**2 + c)**2) + c) % n
p = fractions.gcd(abs(b0 - a0), n)
if(p > 1):
	print ("Found a factor: " + str(p))


while (a0 != b0):
	a0 = (a0**2 + c) % n
	b0 = (((b0**2 + c)**2) + c) % n
	p = fractions.gcd(abs(b0 - a0), n)
	if(p > 1):
		print ("Found a factor: " + str(p))
		n = n / p
