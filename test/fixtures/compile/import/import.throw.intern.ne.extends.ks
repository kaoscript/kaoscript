extern console
extern sealed class EvalError

import '../export/export.throw.intern.ne.extends.ks'

try {
	foo()
}
on EvalError catch error {
	console.error(error)
}