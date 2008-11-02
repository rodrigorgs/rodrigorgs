DIR=myer-rsf
for x in $DIR/*.rsf; do echo $x; time ./plot_degree_dist.rb $x edge; done
