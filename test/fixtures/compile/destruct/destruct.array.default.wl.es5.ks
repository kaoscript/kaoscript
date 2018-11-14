#![format(destructuring='es5')]

extern console: {
	log(...args)
}

let arr = [1, '', true]

let [a, b, c] = arr

console.log(a, b, c)
// <= 1, '',  true