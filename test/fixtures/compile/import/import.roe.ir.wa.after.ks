#![libstd(off)]

extern system class Array

import '../require/require.alt.roe.array.ks'(Array)

impl Array {
	foobar() => 42
}

export Array