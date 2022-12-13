extern console: {
	log(...args)
}

for x from 0 to 10 step 2 until x > 5 {
	console.log(x)
}