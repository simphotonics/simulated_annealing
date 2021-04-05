reset

set key box inside left bottom font ", 12" width -3
##set title "Annealing Schedule" font ",18"

set grid lw 2

set tics font ", 12"

set format y "    %1.E";

set xlabel "Iteration" font ", 12"
set xrange [ * : 755 ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel "" font ", 12"
set yrange [ * : * ] noreverse writeback
set y2range [ * : * ] noreverse writeback


set term qt size 500, 500 font "Sans,12"

 set lmargin at screen 0.15;
# set rmargin at screen 0.8;
# set bmargin at screen 0.2;
# set tmargin at screen 0.8;

set logscale y

plot '../data/log.dat' using ($10) w l  lw 3 lc "#00cc4433" t 'Temperature', \
     '../data/log.dat' using ($4)  w l lw 3 t "Perturbation magnitude: deltaPosition", \
