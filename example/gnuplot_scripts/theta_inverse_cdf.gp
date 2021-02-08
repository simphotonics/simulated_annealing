reset

inverseCdf(p, thetaMin, thetaMax) = acos(-p*(cos(thetaMin) - cos(thetaMax)) + cos(thetaMin))

set samples 1000

set term qt size 500, 500 font "Sans, 14"
set key inside Left bottom right font "Sans, 12" width -8
set grid lw 2

#set tics font ", 16"



set xlabel "Probability"
set xrange [ 0 : 1 ] noreverse writeback
set x2range [ * : * ] noreverse writeback

set ylabel ""
set yrange [ 0 : pi ] noreverse writeback
set y2range [ * : * ] noreverse writeback
set ytics ('0' 0, 'π/4' pi/4, 'π/2' pi/2, '3π/4' 3*pi/4 ,  'π' pi,);


plot inverseCdf(x, 0, pi) lw 3 lt 2 lc '#0000C77E', \
  inverseCdf(x, pi/4, 3*pi/4) lw 3 lt 5 lc '#007E00C7', \
  inverseCdf(x, pi/2-pi/10, pi/2+pi/10) lw 3 lc '#00C77E00'