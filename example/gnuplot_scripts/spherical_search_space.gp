# Visualizes a spherical search space by plotting the points in ../data/spherical_search_space.dat

reset

set term qt size 1000, 1000

set key font ", 14"  inside bottom left enhanced

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

# set parametric
# set isosamples 20,20

# set xlabel 'X'
# set ylabel 'Y'
# set zlabel 'Z'

# R = 2.   # radius of sphere
# set urange [-pi/2:pi/2]
# set vrange [0:2*pi]
# splot R*cos(u)*cos(v),R*cos(u)*sin(v),R*sin(u) w l lc rgb "yellow", \
# "-" w p ps 3 pt 9
# 1 1 0.6
# e

# set style line 1 lt 1 pt 6 lc rgb "#0608aaff" lw 3.5
# set style line 2 lt 2 lw 3 lc rgb "#ffffffff" pt 6 ps 3
# set style line 2 lt 3 lw 3 lc rgb "#ffff00ff" pt 6 ps 3

# unset parametric

splot '../data/spherical_search_space.dat' lt 1 ps 0.5 pt 4 t "Points In Search Space", \
'../data/spherical_search_space_perturbation.dat' ps 0.75 pt 7 lt 2 t "Points In Neighbourhood Around Test Point", \
'../data/spherical_search_space_center_point.dat' ps 2 pt 7 lt 1 lc "red" t "Test Point", \
"-" w p ps 3 pt 9 lt 9 lc "blue" t "Center Point"
0 0 0
e