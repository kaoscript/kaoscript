extern console: {
	log(...args)
}

var dyn number = 13

match number {
	1				=> console.log("One!")
	2, 3, 5, 7, 11	=> console.log("This is a prime")
	13..19			=> console.log("A teen")
	else			=> console.log("Ain't special")
}