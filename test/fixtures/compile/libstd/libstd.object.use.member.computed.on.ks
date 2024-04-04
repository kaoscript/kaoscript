#![libstd(package='./libstd.object.decl.ks')]

func foobar() {
	var values = {}

	quxbaz(values)

	var value = values[0]
}

func quxbaz(values) {
	values['foo'] = 'foo'
}