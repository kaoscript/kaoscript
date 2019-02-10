extern {
	console

	sealed class Number {
		toString(): String
	}
}

import '../require/require.alt.roe.methods.ks'

const a = [1..10]

console.log(`\(a.indexOf(5).toString())`)

console.log(`\(a.pushUniq(5).indexOf(5).toString())`)