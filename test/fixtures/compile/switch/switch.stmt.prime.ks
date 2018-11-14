extern console: {
	log(...args)
}

let number = 13

switch number {
	1				=> console.log("One!")
	2, 3, 5, 7, 11	=> console.log("This is a prime")
	13..19			=> console.log("A teen")
					=> console.log("Ain't special")
}