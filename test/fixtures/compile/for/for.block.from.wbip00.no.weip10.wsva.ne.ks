extern console: {
	log(...args)
}

var dyn y = 2

for x from 0 to 10 step y {
	console.log(x)
}