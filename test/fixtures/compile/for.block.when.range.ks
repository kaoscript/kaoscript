extern console: {
	log(...args)
}

for x in 0..10 when x % 2 == 0 {
	console.log(x)
}