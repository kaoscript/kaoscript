var dyn foo = {
	otto: 'hello :)'
}
var dyn bar = ['otto']
var dyn qux

if qux ?= foo[bar.join(',')] {
}