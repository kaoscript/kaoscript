extern console: {
	log(...args)
}

let [x, y, ..., z] = [1, 2, 3, 4, 5, 6, 7]

console.log(x, y, z)
// <- 1, 2, 7