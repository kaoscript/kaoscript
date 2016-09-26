extern console, parseInt

extern final class String

impl String {
	toInt(base = 10) -> Number => parseInt(this, base)
}

console.log('42'.toInt())