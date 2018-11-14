extern console

extern sealed class Boolean
extern sealed class String

impl Boolean {
	toBoolean(): Boolean => this
}

impl String {
	toBoolean(): Boolean => (/^(?:true|1|on|yes)$/i).test(this)
}

console.log(true.toBoolean())
console.log('true'.toBoolean())