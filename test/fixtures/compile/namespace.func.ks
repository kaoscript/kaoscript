extern console

namespace Float {
	export func toString(value: Number): String => value.toString()
}

console.log(`\(Float.toString(3.14))`)