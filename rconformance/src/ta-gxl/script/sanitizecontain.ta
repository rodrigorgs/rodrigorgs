getta($1)

// If these tuples exist
//  contain package class
//  contain class inner
//  contain package inner
// then we must remove this last tuple

classes = $INSTANCE . {"class"}
packages = $INSTANCE . {"package"}

inner = classes . ((classes o contain) o classes)
contain = contain - ((packages o contain) o inner)

putta($2)
