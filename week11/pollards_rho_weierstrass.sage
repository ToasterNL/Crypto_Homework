# Schoolbook Pollard's Rho with sage
# sage: load pollards_rho.sage

def weierstrass_add(point1,point2):
	x1,x2 = point1
	y1,y2 = point2
	new_x = (y2-y1)^2/(x2-x1)^2-x1-x2
	new_y = (2 * x1+x2) (y2-y1)/(x2-x1)-(y2-y1)^3/(x2-x1)^3-y1
	return new_x, new_y

# how to multiply on weierstrass curve?
def weierstrass_multiply(point1,constant):
	for i in range(0, constant):
		point = weierstrass_add(point, point)
	return point

def weierstrass_double(point1,point2):
	x1,x2=point1
	y1,y2=point2
	new_x = (3*x1^2+a)^2/(2*y1)^2-x1-x1
	new_y = (2*x1+x1) (3*x1^2+a)/(2*y1)-(3*x1^2+a)^3/(2*y1)^3-y1
	return new_x,new_y

class RandomWalkGroup:
	def __init__(self, generator, modulus, target, order):
		self.generator = generator
		self.modulus = modulus
		self.order = order
		self.target = target
		self.t = generator
		self.a = 1
		self.b = 0

	def walk(self):
		rem = self.t%3
		if rem == 0:
			self.t = weierstrass_multiply(self.t,self.generator)
			self.a = weierstrass_add(self.a,(1,1))
		elif rem == 1:
			self.t = weierstrass_multiply(self.t,self.target)
			self.b = weierstrass_add(self.b,(1,1))
		elif rem == 2:
			self.t = weierstrass_multiply(self.t,self.t)
			self.a = weierstrass_double(self.a)
			self.b = weierstrass_double(self.b)

def pollards_rho(p,n,q,order,quiet=False):
	slow = RandomWalkGroup(p,n,q,order)
	fast = RandomWalkGroup(p,n,q,order)
	#if not quiet:
		#print "Solving %i^a = %i (mod %i) using Pollard's Rho method" % (p,q,n)
		#print "%6s %6s %6s %6s %6s %6s" % ('t_i', 'a_i','b_i','t_j','a_j','b_j')
	t = cputime()
	while True:
		print "Sup"
		slow.walk()
		#fast.walk()
		#fast.walk()

		print slow
		#print fast
		break
		#if not quiet:
			#print "%6s %6s %6s %6s %6s %6s" % (slow.t, slow.a, slow.b, fast.t, fast.a, fast.b)

		# The objects created by the random walks have this property
		#assert slow.t == pow(g,slow.a,n) * pow(h,slow.b,n) % n
		#assert fast.t == pow(g,fast.a,n) * pow(h,fast.b,n) % n

		# We're looking for a match
		if slow.t == fast.t:
			print "Sup"
			print slow
			print fast
			break
			# The match property
			#assert pow(g,fast.a,n) * pow(h,fast.b,n) % n == pow(g,slow.a,n) * pow(h, slow.b, n) % n

			a=(slow.a-fast.a) % order
			b=(fast.b-slow.b) % order

			# The relationship we are exploiting
			#assert pow(g,a,n) == pow(h,b,n)

			# Looking for a solution
			if not quiet:
				print "Solving for a in:\n %ia = %i (mod %i)" % (b, a, order)
			d = gcd(b,order)
			# If d|a this can be solved
			if a % d == 0:
				# Solve using linear congruences
				if not quiet:
					print "This has %i solution(s)" % d
				q, r, s = xgcd(b, order)

				# Basis solution
				congruence = (order/d)
				x=((r*a)/d) % congruence
				#assert b*x % order == a

				# Congruent solutions
				for i in range(0,d):
					candidate = x+(i*congruence)
					if pow(g, candidate, n) == h:
						if not quiet:
							print "Found solution: a=%i in %0.3f s\n" % (candidate, cputime()-t)
						return candidate
					elif not quiet:
						print "Candidate %i rejected" % candidate
			elif not quiet:
				print "No solution exists, retrying"

def benchmark(times, n_order):
	n=random_prime(n_order)
	g=random_prime(n)
	# Get actual generator, even though it works with any prime
	while Mod(g,n).multiplicative_order() != n-1: g=random_prime(n)
	t=cputime()
	for i in xrange(0, times):
		h=g**(randint(3,n-1)) % n
		a=pollards_rho(g,n,h,True)
		assert pow(g,a,n) == h
	print "Benchmark of %i runs in F_<%i>%%%i completed in %0.3f s" % (times, g, n, cputime()-t)

def main():
	# Assignment, a=375
	p = (2232, 361)
	q = (699, 835)
	pollards_rho(p, 2347, q, 2389)

	# Benchmark
	#for i in xrange(0,10):
		#benchmark(100, 100000)

if __name__ == "__main__":
    main()

