extern console: {
	log(...args)
}

let temperature = 54

switch temperature {
	0..49 	where temperature % 2 == 0	=> console.log("Cold and even")
	50..79	where temperature % 2 == 0	=> console.log("Warm and even")
	80..110	where temperature % 2 == 0	=> console.log("Hot and even")
										=> console.log("Temperature out of range or odd")
}