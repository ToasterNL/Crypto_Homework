# Index calculus with sage
# sage: load index_calculus.sage

def index_calculus(g,n,h,base,quiet=False):
	order = n-1
	l=len(base)
	rows = [None]*(l+1)
	runs = 0
	t=cputime()
	M=matrix(ZZ, l+1, l+1, sparse=True)
	if not quiet:
		print "Solving %i^a = %i (mod %i) using index calculus method on base %s" % (g,h,n, base)
	while True:
		a=randint(2,order)
		test_h=pow(g,a,n)
		factors = factor(int(test_h))

		# If this value factors into our factor base
		if factors and factors[-1][0] <= base[-1]:
			# That means it's mooth with respect to the factor base
			row = [0]*(l+1)
			# Verify inverses for these factors exist
			for coefficient, exponent in factors:
				d = gcd(coefficient,order)
				if d == 1:
					row[base.index(coefficient)] = exponent
					add = True
				else:
					add = False
					congruence = order/d
					for j in xrange(0,d):
						if g**(exponent+(j*congruence)) % n == coefficient:
							row[base.index(coefficient)]=exponent+(j*congruence)
							add = True
							break
				if not add:
					# Factor has no inverse for this remainder
					break
			if add:
				row[-1]=a
				rows[runs]=row
				runs += 1

			if runs == l+1:
				# System should be determined enough to solve
				M=Matrix(ZZ, rows, sparse=True).echelon_form()
				h_factors = [M[row,l] for row in xrange(0,l)]
				for index, h_factor in enumerate(h_factors):
					# The interesting relationships
					if not (g**h_factor) % n == base[index]:
						# Get more relations
						break

				if (g**h_factor) % n == base[index]:
					# We have a working solution for the system with the log_n of every factor
					# Find s for g^s*h % n to factor
					for s in range(0,order):
						to_factor = ((g**s) * h) % n
						factors = factor(to_factor)
						if factors and factors[-1][0] <= base[-1]:
							# It factors, we have a solution (candidate)
							solution = (sum([x[1]*h_factors[i+1] for i,x in enumerate(factors)]) - s) % order
							if not g**solution % n == h:
								continue
							# The property the want
							assert g**solution % n == h
							if not quiet:
								print "Solved system:"
								print M.echelon_form()[0:l]
								print "Found solution a=%i in %0.03f s" % (solution, cputime()-t)
							return solution
				runs=0

def benchmark(times, base):
	n=1019
	g=2
	t=cputime()
	for i in xrange(0, times):
		h=(g**randint(3,n-1)) % n
		a=index_calculus(g,n,h,base,True)
		assert pow(g,a,n) == h
	print "Benchmark of %i runs in F_<%i>%%%i completed in %0.3f s" % (times, g, n, cputime()-t)

def main():
	# Assignment, a=311
	factor_base = [2,3,5,7,11,13]
	index_calculus(2,1019,281,factor_base)
	#for i in range(0,10):
		#benchmark(10, factor_base)
		

if __name__ == "__main__":
    main()

