FROM_DIR=collab
#TO_DIR=myer-rsf/outXin
for x in $FROM_DIR/*.rsf; do echo $x; time ./plot_in_out.rb $x extends implements aggregates; done
