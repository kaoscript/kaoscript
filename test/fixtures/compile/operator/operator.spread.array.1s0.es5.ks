#![target(ecma-v5)]

let bar = []

func foo(...args) {
	const foo = [42, ...args]
}