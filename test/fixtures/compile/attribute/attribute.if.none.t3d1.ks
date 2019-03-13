#![target(trident-v8)]

extern sealed class String

#[if(none(trident, safari-v8))]
disclose String {
	endsWith(search: String, length: Number = -1): Boolean
}

export String