extern console: {
	log(...args)
}

extern Class

import './_string.ks'(Class)

let foo = 'HELLO!'

console.log(foo)
console.log((foo as string).lower())