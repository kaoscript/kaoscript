let foo = [1, 2]
let bar = []

bar.push(0, ...foo)


extern console: {
	log(...args)
}

func log(...args) {
	console.log(...args)
}

let machine = 'tesla'
let directory = 'xfer'
let user = 'john'

let info := [machine, ':', directory, ' ', user, ': ']

let logHello = log^^(...info)

logHello('foo')