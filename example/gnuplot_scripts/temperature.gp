set key left bottom nobox font ", 12"

set title "Simulated Annealing - System Temperature" font ",18"

set grid lw 2

set xyplane 0

set border 31+32+64+256+512 linecolor rgb "#333333" lw 1.5

set style line 1 lt 1 pt 6 lc rgb "#0608aaff" lw 3.5


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
set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel "Y" font ", 20"
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback

set zlabel "Z" font ", 20"
set zrange [ * : * ] noreverse writeback
set cbrange [ 0 : 100 ] noreverse writeback
set rrange [ * : * ] noreverse writeback



# Gnuplot script plotting a 3D graph of the system energy.
set palette defined (0 "blue", 5 "#4444FF99", 10 "#9999FF99", 15 "turquoise",  30 "turquoise", 40 "green", 70 "yellow",  100 "red" )



splot '../data/log.dat' using 1:2:3:($7) ps 2 pt 7 pal t "System Temperature", \
'../data/spherical_sample_space.dat' using 1:2:3 ps 0.45 lc "#44444455" pt 7 t "Search Region",