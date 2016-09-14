extern console: {
	log(...args)
}

extern Class

import * from ./_string.ks with Class

let foo = 'HELLO!'

console.log(foo)
console.log((foo as string).lower())