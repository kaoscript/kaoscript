extern console

import '../export/export.sealed.namespace.default.ks'

impl Math {
	pi(): Number => 42
}

console.log(Math.pi())