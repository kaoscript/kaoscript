#![libstd(package='./libstd.namespace.decl.ks')]

extern sealed namespace Math {
	PI: Number
	pow(): Number
}

impl Math {
	pi: Number = Math.PI
	foo(): Number => Math.PI
}

export Math