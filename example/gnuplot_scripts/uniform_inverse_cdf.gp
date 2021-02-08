reset

inverseCdf(p, xMin, xMax) = xMin + (xMax - xMin)* p;

set samples 1000

set term qt size 500, 500 font "Sans, 14"

set key inside Left bottom  width -3
set grid lw 2

#set tics font ", 16"



set xlabel "Probability"
set xrange [ 0 : 1 ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel ""
set yrange [ 0 : 10 ] noreverse writeback
set y2range [ * : * ] noreverse writeback


plot inverseCdf(x, 0, 10) lw 3 lt 2 lc '#0000C77E', \
  inverseCdf(x, 2, 8) lw 3 lt 5 lc '#007E00C7', \
  inverseCdf(x, 4, 6) lw 3 lc '#00C77E00'