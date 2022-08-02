extern console, parseFloat

namespace Float {
	var PI = 3.14

	export func toFloat(value: String): Number => PI * parseFloat(value)
	export func toString(value: Number): String => value.toString()
}

console.log(Float.PI)
console.log(Float.toFloat('3.14'))
console.log(`\(Float.toString(3.14))`)