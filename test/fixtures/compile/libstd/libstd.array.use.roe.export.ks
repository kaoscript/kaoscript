#![libstd(package='./libstd.array.decl.ks')]

require|extern system class Array

impl Array {
	copy(): Array {
		return this
	}
}

export Array