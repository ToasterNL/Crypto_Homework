# Schoolbook Pollard's Rho with sage

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

def pollards_rho(g,n,h):
	slow = RandomWalkGroup(g,n,h)
	fast = RandomWalkGroup(g,n,h)
	candidate = g
	print "Solving %i^a = %i (mod %i) using Pollard's Rho method" % (g,h,n)
	print "%6s %6s %6s %6s %6s %6s" % ('t_i', 'a_i','b_i','r_i','a_j','b_j')
	while True:
		slow.walk()
		fast.walk()
		fast.walk()
		print "%6s %6s %6s %6s %6s %6s" % (slow.t, slow.a, slow.b, fast.t, fast.a, fast.b)
		assert slow.t == pow(g,slow.a,n) * pow(h,slow.b,n) % n
		assert fast.t == pow(g,fast.a,n) * pow(h,fast.b,n) % n
		if slow.t == fast.t:
			assert pow(g,fast.a,n) * pow(h,fast.b,n) % n == pow(g,slow.a,n) * pow(h, slow.b, n) % n
			a=(slow.a-fast.a) % (n-1)
			b=(fast.b-slow.b) % (n-1)
			assert pow(g,a,n) == pow(h,b,n)
			print "Solving for a in:\n %ia = %i (mod %i)" % (b,a, (n-1))
			d = gcd(b,n-1)
			if a % d == 0:
				# Solve using linear congruence
				print "This has %i solution(s)" % d
				q, r, s = xgcd(b,n-1)
				# Basis solution
				x=((r*a)/d) % ((n-1)/d)
				assert b*x % (n-1) == a
				# Congruent solutions
				for i in range(0,d):
					candidate = x+(i*(n-1)/d)
					if pow(g, candidate, n) == h:
						print "Found solution: a=%i\n" % candidate
						return candidate
					else:
						print "Candidate %i rejected" % candidate
			else:
				print "No solution exists, retrying"

def test():
	import random
	g=random_prime(100)
	n=random_prime(10000)
	for i in xrange(0,100):
		h=(g**random.randint(3,n-1)) % n
		a=pollards_rho(g,n,h)
		assert pow(g,a,n) == h

def main():
	# Assignment, a=375
	pollards_rho(3,1013,245)

	# Wikipedia example, a=10
	#pollards_rho(2,1019,5)

	# Test, a=456
	#pollards_rho(3,1013,732)

	# Test, a=123
	#pollards_rho(3,1091,25)

	# Test it
	#test()

if __name__ == "__main__":
    main()
