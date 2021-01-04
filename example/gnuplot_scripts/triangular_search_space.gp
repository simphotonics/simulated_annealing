# Visualizes a spherical search space by
# plotting the points in ../data/spherical_search_space.dat

reset

set term qt size 1000, 600

set key font ", 14"  inside bottom left enhanced

set tics font ", 14"

#set title "Spherical Search Space" font ",18"

set grid lw 2


plot '../data/triangular_search_space.dat' lt 1 ps 0.5 pt 4 t "Points In Search Space", \
'../data/triangular_search_space_perturbation.dat' ps 0.75 pt 7 lt 2 t "Points In Neighbourhood Around Test Point", \
'../data/triangular_search_space_center_point.dat' ps 2 pt 7 lt 1 lc "red" t "Test Point", \
"-" w p ps 2 pt 9 lt 9 lc "blue" t "Center Point"
0 0
e