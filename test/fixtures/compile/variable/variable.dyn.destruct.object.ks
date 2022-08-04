extern console

func foo() => {
	x: 1
	y: 2
}

var dyn {x, y} = foo()

console.log(x, y)