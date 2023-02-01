extern foo, bar, qux

var x = if foo() {
	var dyn y = 0
	
	for var i from 1 to 10 {
		y += bar(i)
	}
	
	pick y
}
else {
	pick bar()
}