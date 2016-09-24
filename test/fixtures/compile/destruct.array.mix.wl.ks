extern console: {
	log(...args)
}

let a = 'foobar'

let arr = [1, '', true]

let [a, b, c] = arr

console.log(a, b, c)
// <= 1, '',  true