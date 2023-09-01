extern console: {
	log(...args)
}

extern a

var dyn b

if ?(b <- a.b).c {
	console.log(b)
}