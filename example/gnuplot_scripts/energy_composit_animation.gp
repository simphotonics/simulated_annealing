reset

load 'energy2d.gp'

set key left top nobox font ", 12"

unset key

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


set tics font ", 12"
set cbtics font ", 12" offset 0,0.5,0

set xtics ('-2' -2.0, '-1' -1.0, '0' 0.0, '1' 1.0, '2' 2.0);
set ytics ('-2' -2.0, '-1' -1.0, '0' 0.0, '1' 1.0, '2' 2.0);



set xlabel "X" font ", 16" offset 2,0.25,0
set xrange [ -2 : 2 ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel "Y" font ", 16" offset -2,0,0
set yrange [ -2 : 2 ] noreverse writeback
set y2range [ * : * ] noreverse writeback

set zlabel "Z" font ", 16" offset -10, 0, 0
set zrange [ -2 : 2 ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback

set cbrange [0: 4]


# Gnuplot script plotting a 3D graph of the system energy.


set term pngcairo size 1000, 500 font "Sans,14"


# set lmargin at screen 0.2;
# set rmargin at screen 0.8;
# set bmargin at screen 0.2;
# set tmargin at screen 0.8;

set colorbox user noborder horizontal origin .3,.075 size .4,.025

# splot '../data/spherical_search_space2D.dat' using 1:2:3 ps 0.5 lt 1 pt 7 lc "#44444455" t "Search Region", \
#   '../data/animation/log_5.dat' using 1:2:3:4 ps 1.5 pt 7 pal t "System energy"


do for [i=0:299] {

    print(i);
    set output sprintf('../plots/animation/composit_%i.png', i)
    set multiplot layout 1, 2
    set zrange [ -2 : 2 ] noreverse writeback
    set zlabel "Z" font ", 14" offset 2
    set ztics ('-2' -2.0, '-1' -1.0, '0' 0.0, '1' 1.0, '2' 2.0);
    set palette defined (0 "#2233DD", 0.25 "blue",  2 "green", 3.5 "yellow",   4 "red" )
    set title "System Energy 3D" font ",14"
    splot '../data/spherical_space.dat' using 1:2:3 ps 0.5 lt 1 pt 7 lc "#757575", \
      sprintf('../data/animation/log_%i', i) using 1:2:3:7 ps 1.0 pt 7 pal

    set title "System Energy (X-Y Projection)" font ",14"
    set zrange [ 0 : 4 ] noreverse writeback
    set zlabel "E" font ", 16" offset 2
    set ztics ('0' 0, '1' 1.0, '2' 2.0, '3' 3.0, '4' 4.0);

    set isosamples 30, 30
    set samples 1000, 1000

#set palette defined (0 "red", 3 "yellow", 5 "green", 8 "turquoise",  10 "blue" )
#set contour both
#set cntrparam levels incr 0, 0.5, 3
    splot energy2d(x,y) lw 1 t 'Energy', \
    sprintf('../data/animation/log_%i', i) using 1:2:7:7 ps 1 pt 7 pal
    unset multiplot


}