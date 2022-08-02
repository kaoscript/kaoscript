extern console: {
	log(...args)
}

var dyn left = 10
var dyn right = 20

if right > left {
	[left, right] = [right, left]
}

console.log(left, right)
// <- 20, 10