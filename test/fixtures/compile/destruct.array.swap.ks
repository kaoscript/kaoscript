extern console: {
	log(...args)
}

let left = 10
let right = 20

if right > left {
	[left, right] = [right, left]
}

console.log(left, right)
// <- 20, 10