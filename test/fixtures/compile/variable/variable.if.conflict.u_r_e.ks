extern console

var dyn index = 0

console.log(index)

if true {
	console.log(index)

	var dyn index = 42

	console.log(index)
}

console.log(index)