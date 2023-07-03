extern console: {
	log(...args)
}

var dyn foo = () => 'otto'
var dyn qux = () => 'itti'
var dyn x

if x ?= foo() {
	console.log(x)
}
else if x ?= qux() {
	console.log(x)
}