type Foobar = {
	parent: Foobar?
}

var f1: Foobar = {}
var f2: Foobar = {
	parent: f1
}