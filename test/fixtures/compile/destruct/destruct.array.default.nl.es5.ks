#![target(ecma-v5)]

extern console: {
	log(...)
}

arr = [1, '', true]

[a, b, c] = arr

console.log(a, b, c)
// <= 1, '',  true