extern console: {
	log(...args)
}

var dyn temperature = 83

switch temperature {
	0..49	=> console.log("Cold")
	50..79	=> console.log("Warm")
	80..110	=> console.log("Hot")
			=> console.log("Temperature out of range")
}