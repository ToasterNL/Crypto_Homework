def index_calculus(g,n,h,base):
	order = n-1
	l=len(base)
	rows = []
	runs = 0
	t=cputime()
	while True:
		a=randint(2,order)
		test_h=pow(g,a,n)
		factors = factor(int(test_h))

		# If this value factors into our factoring base
		if factors and factors[-1][0] <= base[-1]:
			# Smooth with respect to factor base
			row = [0]*(l+1)
			# Verify inverses exist
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
					# Factor without inverse for this remainder
					break
			if add:
				# TODO Only add new relations
				row[-1]=a
				rows.append(row)
				runs += 1

			if runs == 3*l: # Teporary fix: should find a way to only add independent vectors to the system
				# System should be determined enough to solve
				M=Matrix(ZZ, rows, sparse=True).echelon_form()
				h_factors = [M[row,l] for row in xrange(0,l)]
				for index, h_factor in enumerate(h_factors):
					assert (g**h_factor) % n == base[index]
				for s in range(0,order):
					to_factor = ((g**s) * h) % n
					factors = factor(to_factor)
					if factors and factors[-1][0] <= base[-1]:
						solution = sum([x[1]*h_factors[i+1] for i,x in enumerate(factors)]) - s
						assert g**solution % n == h 
						print "Found solution %i in %0.03f s" % (solution, cputime()-t)
						return solution
				i=0

def main():
	# Assignment, a=1329
	factor_base = [2,3,5,7,11,13]
	a = index_calculus(2,1019,281,factor_base)

if __name__ == "__main__":
    main()

