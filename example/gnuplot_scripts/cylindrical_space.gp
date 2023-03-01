# Visualizes a cylindrical search space by
# plotting the points in ../data/cylindrical_space.dat

reset

set key font ", 12"  inside top right enhanced

#set title "Spherical Search Space" font ",18"

set grid lw 2

set xyplane 0

#set border 31+32+64+256+512 linecolor rgb "#333333" lw 1.5

set tics font ", 14"

#set xlabel "X" font ", 20"
set xrange [ -2 : 2 ] noreverse writeback
set x2range [ * : * ] noreverse writeback

#set ylabel "Y" font ", 20"
set yrange [ -2 : 2 ] noreverse writeback
set y2range [ * : * ] noreverse writeback

#set zlabel "Z" font ", 20"
set zrange [ -2 : 2 ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback

set xtics ('-2' -2.0, '-1' -1.0, '0' 0.0, '1' 1.0, '2' 2.0);
set ytics ('-2' -2.0, '-1' -1.0, '0' 0.0, '1' 1.0, '2' 2.0);
set ztics ('-2' -2.0, '-1' -1.0, '0' 0.0, '1' 1.0, '2' 2.0);

set term qt size 500, 500 font "Sans,12"

set margin 10, 1,1 ,1

#set mapping spherical



#set output '../plots/spherical_space_surface_test.png'

splot '../data/cylindrical_space.dat' lt 1 ps 0.4 pt 7 t "Points In Search Space", \
'..data/cylindrical_space_perturbation.dat' ps 0.75 pt 7 lt 2 t "Random Points Around Test Point", \
'../data/cylindrical_space_test_point.dat' ps 2 pt 7 lt 1 lc "red" t "Test Point", \
"-" w p ps 3 pt 9 lt 9 lc "blue" t "Origin"
0 0 0
e