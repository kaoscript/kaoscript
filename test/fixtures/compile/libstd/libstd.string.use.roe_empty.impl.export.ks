#![libstd(package='./libstd.string.decl.ks')]

require|extern system class String {
}

extern parseFloat, parseInt

impl String {
	toFloat(): Number => parseFloat(this)
	toInt(base = 10): Number => parseInt(this, base)
}

export String