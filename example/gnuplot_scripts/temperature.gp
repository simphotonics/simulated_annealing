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

set cbtics font ", 12"

# Reading maximum temperature
stats '../data/log.dat' using 10 nooutput
tmax = STATS_max

#set xlabel "X" font ", 14"
set xrange [ * : * ] noreverse writeback
set x2range [ * : * ] noreverse writeback

#set ylabel "Y" font ", 14"
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback

#set zlabel "Z" font ", 14"
set zrange [ * : * ] noreverse writeback
set cbrange [ 0 : tmax ] noreverse writeback
set rrange [ * : * ] noreverse writeback

set xtics ('-2' -2.0, '-1' -1.0, '0' 0.0, '1' 1.0, '2' 2.0);
set ytics ('-2' -2.0, '-1' -1.0, '0' 0.0, '1' 1.0, '2' 2.0);
set ztics ('-2' -2.0, '-1' -1.0, '0' 0.0, '1' 1.0, '2' 2.0);

# Gnuplot script plotting a 3D graph of the system energy.
set palette defined (tmax*0.001 "blue", tmax*0.005 "#4444FF99", tmax*0.01 "#9999FF99", \
  tmax*0.05 "turquoise",  tmax*0.15 "green", tmax*0.45 "yellow",  tmax "red" )

set term pngcairo size 500, 500 font "Sans,12"

unset colorbox

set colorbox user origin .8,.4 size .02,.4

set output '../plots/temperature.png'


splot  '../data/spherical_search_space2D.dat' using 1:2:3 ps 0.45 lc "#44444455" pt 7 t "Search Region",\
'../data/log.dat' using 1:2:3:($10) ps 2 pt 7 pal t "System Temperature",