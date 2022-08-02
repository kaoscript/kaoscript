extern console: {
	log(...)
}

var dyn arr = [1, '', true]

var dyn [a, b, c] = arr

console.log(a, b, c)
// <= 1, '',  true