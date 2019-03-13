#![target(trident-v8)]

extern sealed class String

#[if(any(trident, safari-v8))]
impl String {
	endsWith(value: String): Boolean => this.length >= value.length && this.slice(this.length - value.length) == value
}

#[else]
disclose String {
	endsWith(search: String, length: Number = -1): Boolean
}

export String