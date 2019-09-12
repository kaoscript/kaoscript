#![target(trident-v8)]

#[rules(non-exhaustive)]
extern sealed class String {
	length: Number
}

#[if(any(trident, jsc-v8))]
impl String {
	endsWith(value: String): Boolean => this.length >= value.length && this.slice(this.length - value.length) == value
}

#[else]
disclose String {
	endsWith(search: String, length: Number = -1): Boolean
}

export String