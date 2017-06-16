extern console: {
	log(...args)
}

import './export.default.ks' for name => foo

console.log(foo)