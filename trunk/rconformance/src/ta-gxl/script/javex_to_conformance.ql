getta($1);

// remove directories and sources
sources = $INSTANCE . {"S"};
delset(sources);

// rename entities
$INSTANCE = replace($INSTANCE, "&1/D/package/");
$INSTANCE = replace($INSTANCE, "&1/C/class/");
$INSTANCE = replace($INSTANCE, "&1/I/class/"); // interface
$INSTANCE = replace($INSTANCE, "&1/M/method/");
$INSTANCE = replace($INSTANCE, "&1/V/field/");
$INSTANCE = replace($INSTANCE, "&1/A/field/");

// rename relations

// E262 => array of
// E256 => method override

rels = 
  {"E258"}X{"extends"} + 
  {"E259"}X{"implements"} +
  {"E260"}X{"contain"} +
  {"E261"}X{"throws"} +
  {"E193"}X{"is"}
  ;

for orig in dom(rels) {
	targ = pick({orig} . rels);

	$targ = $orig;
	delete $orig;

	for name in relnames {
		$name = replace($name, "&0/" + orig + "/" + targ + "/");
	}
}

delete rels;

// extends = E258;
// delete E258;
// for rel in relnames {
// 	$rel = replace($rel, "&0/E258/extends/");
// }

putta($2);
