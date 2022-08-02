extern console

var dyn foo = () => 'otto'
var dyn qux = () => 'itti'

if x ?= foo() {
	console.log(x)
}
else {
	if x ?= qux() {
		console.log(x)
	}
}