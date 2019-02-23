extern console

let foo = () => 'otto'
let qux = () => 'itti'

if x ?= foo() {
	console.log(x)
}
else {
	if x ?= qux() {
		console.log(x)
	}
}