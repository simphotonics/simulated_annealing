# Visualizes a spherical search space by
# plotting the points in ../data/spherical_search_space.dat

reset


set key box font ", 12"  inside top left enhanced

set tics font ", 14"

set yrange [ -175 : 175 ] noreverse writeback

#set title "Spherical Search Space" font ",18"

set grid lw 2

set term qt size 500, 500

plot '../data/triangular_search_space.dat' lt 1 ps 0.4 pt 7 t "Points In Search Space", \
 '../data/triangular_search_space_perturbation.dat' ps 0.6 pt 7 lt 2 t "Perturbation Points", \
 '../data/triangular_search_space_center_point.dat' ps 2 pt 7 lt 1 lc "red" t "Test Point", \
 "-" w p ps 2 pt 9 lt 9 lc "blue" t "Center Point"
 0 0
 e