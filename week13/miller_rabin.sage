def miller_rabin(n):
  k = 3
  t = 1
  r = 1
  while pow(2,r)*t != n-1:
    r = log((n-1)/t,2)
    if r == floor(r):
      break
    t+=2
    if t >= n-1:
      return 'composite'
  assert pow(2,r) * t == n -1
  print 'n-1 = %i = 2^%i * %i ' % (n-1,r,t)
  for i in range(0,k):
    a=randint(2,n-1)
    if gcd(a,n) % n != 1:
      return 'composite'
    a = a^t
    if a % n != 1 and a % n != -1:
      for j in range(1,r-1):
        a = pow(a,2,n)
        if a == 1:
          return 'composite'
        if a % n == -1:
          break
        return 'composite'
  return 'prime with probability %0.2f' % (1-pow(4,-k))
print miller_rabin(263)
