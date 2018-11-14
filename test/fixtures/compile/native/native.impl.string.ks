extern console, parseInt

extern sealed class String

impl String {
	toInt(base = 10): Number => parseInt(this, base)
}

console.log('42'.toInt())