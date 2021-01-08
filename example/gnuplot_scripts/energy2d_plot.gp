reset

set term qt size 1000, 1000

load 'energy2d.gp'

set key font ", 12"

set title "System Energy" font ",18"

set style line 1 lt 1 pt 6 lc rgb "#0608aaff" lw 3.5

set grid lw 2

set xyplane 0

set border 31+32+64+256+512 linecolor rgb "#333333" lw 1.5

set tics font ", 14"

set xlabel "X" font ", 20"
set xrange [ -2 : 2 ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel "Y" font ", 20"
set yrange [ -2 : 2 ] noreverse writeback
set y2range [ * : * ] noreverse writeback

set zlabel "E" font ", 20"
set zrange [ 0 : 4 ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback

set isosamples 70, 70
set samples 1000, 1000

set palette defined (0 "red", 3 "yellow", 5 "green", 8 "turquoise",  10 "blue" )
set contour both
set cntrparam levels incr 0, 0.5, 3


# Gnuplot script plotting a 3D graph of the system energy.


set hidden

set term qt size 1000, 1000 font "Sans,14"

splot energy2d(x,y) lw 1.5 t 'Energy'