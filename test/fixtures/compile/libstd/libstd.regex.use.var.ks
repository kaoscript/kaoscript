#![libstd(package='./libstd.regex.decl.ks')]

func foobar(value: String, matcher: RegExp) {
	var match = matcher.exec(value)
}