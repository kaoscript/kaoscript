extern console: {
	log(...args)
}

for x from 0 til 10 when x % 2 == 0 {
	console.log(x)
}