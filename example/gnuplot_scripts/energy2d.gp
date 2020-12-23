# System energy (example)
x0 = 0.5
y0 = 0.7
x1 = -1.0
y1 = -1.0
energy2d (x,y) = (x**2 + y**2) > 4 ? 5.0 : 4.0 - 4.0 * exp(-4 * ( (x0 -x)**2 + (y0-y)**2 ) ) \
 - 2.0 * exp( -6 * ( (x1 - x)**2 + (y1 - y)**2 ) )
