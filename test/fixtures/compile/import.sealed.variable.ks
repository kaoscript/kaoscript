import * from ./export.sealed.variable.ks

extern console

impl Math {
	pi(): Number => 42
}

console.log(Math.pi())