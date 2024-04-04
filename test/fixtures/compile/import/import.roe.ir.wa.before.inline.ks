#![libstd(off)]

extern system class Array

impl Array {
	copy(x) => x
}

import '../require/require.alt.roe.array.ks'(Array)

export Array