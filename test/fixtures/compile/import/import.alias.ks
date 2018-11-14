extern console: {
	log(...args)
}

import '../export/export.default.ks' for name => foo

console.log(foo)