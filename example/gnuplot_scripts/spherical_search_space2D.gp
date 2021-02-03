# Visualizes a spherical search space by plotting the points in ../data/spherical_search_space.dat

reset

set term qt size 1000, 1000

set key font ", 14"  inside top right enhanced

#set title "Spherical Search Space" font ",18"

set grid lw 2

set xyplane 0

#set border 31+32+64+256+512 linecolor rgb "#333333" lw 1.5

set tics font ", 14"

set xlabel "X" font ", 20"
set xrange [ -2 : 2 ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel "Y" font ", 20"
set yrange [ -2 : 2 ] noreverse writeback
set y2range [ * : * ] noreverse writeback

set zlabel "Z" font ", 20"
set zrange [ -2 : 2 ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback

set term qt size 1000, 1000 font "Sans,14"


splot '../data/spherical_search_space2D.dat' lt 1 ps 0.5 pt 4 t "Points In Search Space", \
'../data/spherical_search_space2D_perturbation.dat' ps 0.75 pt 7 lt 2 t "Points In Neighbourhood Around Test Point", \
'../data/spherical_search_space2D_test_point.dat' ps 2 pt 7 lt 1 lc "red" t "Test Point", \
"-" w p ps 3 pt 9 lt 9 lc "blue" t "Origin"
0 0 0
e