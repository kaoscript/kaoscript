extern console: {
	log(...args)
}

import name as foo from ./export.default.ks

console.log(foo)