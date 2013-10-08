g=123
h_a=234
h_b=456
p=1009
i=0
a=None
b=None
e = 0
while not (a and b):
  e=(e+g)%p
  i+=1
  if e == h_a:
    a=i
    print "A=%i" % a
  if e == h_b:
    b=i
    print "B=%i" % b

assert g*a%p == h_a
assert g*b%p == h_b
assert h_a*b % p == h_b*a % p
print "Secret: %i" % (h_a*b % p)
