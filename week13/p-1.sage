M = 1
def pminus1(n, b):
    a = 2
    M = 1
    for q in primes(b):
      M = M*pow(q,floor(log(b,q)))
    g = gcd(pow(a,M,n)-1, n)
    if 1 < int(g) and int(g) < n:
      return g
    return False

n=53098980256925153592047
f1= int(pminus1(n,128))
f2= int(n/f1)
print "n = %u = %u*%u" % (n,f1,f2)
assert f1*f2 == n

