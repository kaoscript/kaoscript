import './_array.ks'

extern console: {
	log(...args)
}

func foo(...items) {
	console.log(items.last())
}