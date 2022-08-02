var foo = [1, 2]
var bar = []

bar.push(0, ...foo)


extern console: {
	log(...args)
}

func log(...args) {
	console.log(...args)
}

var dyn machine = 'tesla'
var dyn directory = 'xfer'
var dyn user = 'john'

var dyn info = [machine, ':', directory, ' ', user, ': ']

var dyn logHello = log^^(...info)

logHello('foo')