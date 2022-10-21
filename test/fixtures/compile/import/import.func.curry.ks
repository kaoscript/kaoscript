import '../export/export.func.curry.ks'

func foobar(prefix, name) {
	return prefix + name
}

var f = Function.curry(foobar, 'Hello ')