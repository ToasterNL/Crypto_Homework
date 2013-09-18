import math
p=1000003
m=454356542435979283475928437
r=483754
s=342534
terms=[]
n = int(math.floor(math.log(m,p)))
terms = [(i, m / p**i % p) for i in range(0,n+1)]
tot = sum([j*(p**i) for i,j in terms])
assert tot == m
a = (sum([j*(r**(i+1)) for i,j in terms]) + s) % p
print a



