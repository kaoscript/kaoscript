extern console, parseInt

extern sealed class String

impl String {
	toInt(base = 10): Number => parseInt(this, base)
}

var dyn d = 4
var dyn u = 2

console.log(`\(d)\(u)`.toInt())