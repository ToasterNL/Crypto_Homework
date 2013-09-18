p=1000003
m=454356542435979283475928437
r=483754
s=342534
terms=[]
n=0

highest = 0
temp_m = m
while temp_m > p:
  temp_m/=p
  highest+=1

n = highest
temp_m = m
while temp_m > 0:
  term = p**n
  coefficient = temp_m/term
  terms.append((coefficient,n))
  temp_m-=coefficient*term
  n-=1

fancy_terms=[]
tot = 0
for i,j in terms:
  fancy_terms.append("%i*p^%i" % (i,j))
  tot += i*(p**j)

assert tot == m

def a(terms, r, s, p):
  return (sum([part[0]*(r**(part[1]+1)) for part in terms]) + s) % p

print "m = %s" % " + ".join(fancy_terms)
fancy_terms = ["%i*r^%i" % (part[0], (part[1]+1)) for part in terms] + ["+ s % p"]
print "a = %s" % " + ".join(fancy_terms)
print "a = %s" % a(terms, r, s, p)
