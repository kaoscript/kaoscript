extern console: {
	log(...args)
}

for x from 0 to 10 by 2 {
	if x > 5 {
		break
	}
	
	console.log(x)
}