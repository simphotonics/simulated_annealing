set key inside box right top font ", 14"

set title "Annealing Schedule" font ",18"

set grid lw 2

set tics font ", 16"

set format y "    %1.E";

set xlabel "Iteration" font ", 20"
set xrange [ * : 750 ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel "" font ", 20"
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback


plot '../data/temperatures.dat' using ($1)  w l lw 3 lc "#00cc4433" t 'Temperature', \
     '../data/dx.dat' using ($1)  w l lw 3 t "Neighbourhood function dx", \
