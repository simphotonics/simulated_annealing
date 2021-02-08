reset

load 'energy2d.gp'

set term qt size 565, 500 font "Sans,14"

set key font ", 12" width -8
#set title "System Energy" font ",18"

set style line 1 lt 1 pt 6 lc rgb "#0608aaff" lw 3.5

set grid lw 2

set xyplane 0

#set border 31+32+64+256+512 linecolor rgb "#333333" lw 1.5

set tics font ", 14"

set xlabel "X"
set xrange [ -2 : 2 ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel "Y"
set yrange [ -2 : 2 ] noreverse writeback
set y2range [ * : * ] noreverse writeback

set zlabel ""
set zrange [ 0 : 4 ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback

set isosamples 50, 50
set samples 100, 100

set palette defined (0 "red", 3 "yellow", 5 "green", 8 "turquoise",  10 "blue" )
set contour both
set cntrparam levels incr 0, 0.5, 3

unset key
# Gnuplot script plotting a 3D graph of the system energy.


set hidden



splot energy2d(x,y) lw 1.5 t 'Energy'