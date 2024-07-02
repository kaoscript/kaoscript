class Foobar {
}

type Quxbaz = {
	value: Foobar
}

import './require.alt.roi.alias.ce.roi.nfn.ks'(Foobar, Quxbaz)

func foobar(value: Quxbaz) {
}

func quxbaz() {
	var foo = Foobar.new()

	foobar({ value: foo })
}

quxbaz()