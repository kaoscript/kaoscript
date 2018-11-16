const foo = [1, 2]
const bar = []

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

const info = [directory, ' ', user, ': ']

const logHello = log^^(machine, ':', ...info)

logHello('foo')