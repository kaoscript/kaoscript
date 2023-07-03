extern console: {
	log(...)
}

var arr = [1, '', true]

[a, b, c] = arr

console.log(a, b, c)
// <= 1, '',  true