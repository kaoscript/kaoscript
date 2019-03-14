#![target(ecma-v6)]

extern sealed class String

#[if(none(trident, jsc-v8))]
disclose String {
	endsWith(search: String, length: Number = -1): Boolean
}

export String