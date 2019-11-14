#![rules(ignore-misfit)]

extern console

import '../_/_number'
import '../_/_string'

type NS = Number | String

func foobar() {
	let x, y

	if quxbaz('foobar') && quxbaz(x = 'quxbaz') {
		console.log(x.toInt())
		console.log(y.toInt())
	}

	console.log(x.toInt())
	console.log(y.toInt())
}

func quxbaz(x): Boolean => true