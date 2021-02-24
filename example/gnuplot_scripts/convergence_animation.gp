reset

set term pngcairo size 1000, 500

set key inside right top font ", 12"

set title "Simulated Annealing - Convergence" font ",14"

set grid lw 2

set xyplane 0

set border 31+32+64+256+512 linecolor rgb "#333333" lw 1.5


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

set xlabel "Iteration" font ", 14"
set xrange [ * : 300 ] noreverse writeback
set x2range [ * : * ] noreverse writeback

#set ylabel "" font ", 20"
set yrange [ -2 : 5 ] noreverse writeback
set y2range [ * : * ] noreverse writeback

#set zlabel "" font ", 20"
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback

stats '../data/animation/log_0' using 10 nooutput
scale = 3/STATS_max



do for [i=0:299] {
    print(i);
    set output sprintf('../plots/animation/convergence_%i.png', i)

     plot sprintf('../data/animation/log_%i',i) using 9 ps 2 pt 9 lc "#007300c7" t 'Acceptance Probability', \
       sprintf('../data/animation/log_%i',i) using ($7) ps 1.2 pt 7 lc "#00FFA144" t "System Energy", \
       sprintf('../data/animation/log_%i',i) using ($10*scale) w l lw 4  lc "#00FF4545" t sprintf('Temperature * %.2f', scale), \
       sprintf('../data/animation/log_%i',i) using ($1) w l lw 4 lc "#0000c77e"t "X - Coordinate"

}