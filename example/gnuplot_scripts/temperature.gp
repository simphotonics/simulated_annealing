reset

set key left top nobox font ", 12"

#set title "Simulated Annealing - System Temperature" font ",18"

set grid lw 2

set xyplane 0

#set border 31+32+64+256+512 linecolor rgb "#333333" lw 1.5

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

set tics font ", 12"

set cbtics font ", 9"

#set xlabel "X" font ", 14"
set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback

#set ylabel "Y" font ", 14"
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback

#set zlabel "Z" font ", 14"
set zrange [ * : * ] noreverse writeback
set cbrange [ 0 : 2000 ] noreverse writeback
set rrange [ * : * ] noreverse writeback



# Gnuplot script plotting a 3D graph of the system energy.
set palette defined (2 "blue", 10 "#4444FF99", 20 "#9999FF99", 100 "turquoise",  250 "green", 600 "yellow",  2000 "red" )

set term qt size 565, 500 font "Sans,12"

unset colorbox

set colorbox user origin .8,.4 size .01,.4


splot '../data/log.dat' using 1:2:3:($10) ps 2 pt 7 pal t "System Temperature", \
'../data/spherical_search_space2D.dat' using 1:2:3 ps 0.45 lc "#44444455" pt 7 t "Search Region",