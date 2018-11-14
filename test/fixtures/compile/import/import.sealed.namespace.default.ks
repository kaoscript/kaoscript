import '../export/export.sealed.namespace.default.ks'

extern console

impl Math {
	pi(): Number => 42
}

console.log(Math.pi())