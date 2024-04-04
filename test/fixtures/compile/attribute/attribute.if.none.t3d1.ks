#![libstd(off)]
#![target(trident-v8)]

extern system class String

#[if(none(trident, jsc-v8))]
disclose String {
	endsWith(search: String, length: Number = -1): Boolean
}

export String