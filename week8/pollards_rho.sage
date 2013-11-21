# Schoolbook Pollard's Rho with sage
# sage: load pollards_rho.sage

class RandomWalkGroup:
	def __init__(self, generator, modulus, target):
		self.generator = generator
		self.modulus = modulus
		self.target = target
		self.t = generator
		self.a = 1
		self.b = 0

	def walk(self):
		rem = self.t%3
		if rem == 0:
			self.t = (self.t*self.generator) % self.modulus
			self.a = (self.a+1) % (self.modulus-1)
		elif rem == 1:
			self.t = (self.t*self.target) % self.modulus
			self.b = (self.b+1) % (self.modulus-1)
		elif rem == 2:
			self.t = (self.t*self.t) % self.modulus
			self.a = (self.a*2) % (self.modulus-1)
			self.b = (self.b*2) % (self.modulus-1)

def pollards_rho(g,n,h,quiet=False):
	slow = RandomWalkGroup(g,n,h)
	fast = RandomWalkGroup(g,n,h)
	candidate = g
	order = n-1
	if not quiet:
		print "Solving %i^a = %i (mod %i) using Pollard's Rho method" % (g,h,n)
		print "%6s %6s %6s %6s %6s %6s" % ('t_i', 'a_i','b_i','r_i','a_j','b_j')
	t = cputime()
	while True:
		slow.walk()
		fast.walk()
		fast.walk()
		if not quiet:
			print "%6s %6s %6s %6s %6s %6s" % (slow.t, slow.a, slow.b, fast.t, fast.a, fast.b)

		# The objects created by the random walks have this property
		#assert slow.t == pow(g,slow.a,n) * pow(h,slow.b,n) % n
		#assert fast.t == pow(g,fast.a,n) * pow(h,fast.b,n) % n

		# We're looking for a match
		if slow.t == fast.t:
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
		h=(g**randint(3,n-1)) % n
		a=pollards_rho(g,n,h,True)
		assert pow(g,a,n) == h
	print "Benchmark of %i runs in F_<%i>%%%i completed in %0.3f s" % (times, g, n, cputime()-t)

def main():
	# Assignment, a=375
	pollards_rho(3,1013,245)

	# Benchmark
	#for i in xrange(0,10):
		#benchmark(100, 100000)

if __name__ == "__main__":
    main()
