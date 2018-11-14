extern console, parseInt

extern sealed class String

impl String {
	toInt(base = 10): Number => parseInt(this, base)
}

let d = 4
let u = 2

console.log(`\(d)\(u)`.toInt())