#![rules(ignore-misfit)]

func foobar(x: Number) {
}

foobar('')

include {
	#[rules(dont-ignore-misfit)]
	'./include.attribute.byfile.slave.ks'
}