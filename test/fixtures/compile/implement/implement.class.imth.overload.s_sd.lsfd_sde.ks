extern system class String

impl String {
	unquote(quote: String, escape: String = ''): String => @unquote([quote], escape)
	unquote(quote: Array<String> = ['"', "'"], escape: String = ''): String {
		return this
	}
}

export String