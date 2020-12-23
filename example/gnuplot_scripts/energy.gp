reset

set key font ", 12"

set title "Simulated Annealing - System Energy" font ",18"

set grid lw 2

set xyplane 0

set border 31+32+64+256+512 linecolor rgb "#333333" lw 1.5


#  Bit     plot        splot
#                1   bottom      bottom left front
#                2   left        bottom left back
#                4   top         bottom right front
#                8   right       bottom right back
#               16   no effect   left vertical
#               32   no effect   back vertical
#               64   no effect   right vertical
#              128   no effect   front vertical
#              256   no effect   top left back
#              512   no effect   top right back
#             1024   no effect   top left front
#             2048   no effect   top right front
#             4096   polar       no effect

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

set cbrange [0: 4]


# Gnuplot script plotting a 3D graph of the system energy.
set palette defined (0 "blue", 1 "turquoise", 2 "green", 3 "yellow",  4 "red" )

splot '../data/spherical_sample_space.dat' using 1:2:3 ps 0.25 lt 1 pt 7 t "Search Region", \
 '../data/log.dat' using 1:2:3:4 ps 1 pt 7 pal t "System energy"
