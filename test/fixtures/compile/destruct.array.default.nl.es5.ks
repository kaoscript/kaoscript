#![cfg(format(destructuring='es5'))]

extern console: {
	log(...args)
}

arr = [1, '', true]

[a, b, c] = arr

console.log(a, b, c)
// <= 1, '',  true