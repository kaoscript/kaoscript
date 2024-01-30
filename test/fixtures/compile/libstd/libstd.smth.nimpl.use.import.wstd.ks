#![libstd(package='./libstd.smth.nimpl.decl.ks')]

extern echo

import './libstd.smth.nimpl.use.export.ks'

func foobar(value: Object) {
	echo(Object.length(value))
}

export *