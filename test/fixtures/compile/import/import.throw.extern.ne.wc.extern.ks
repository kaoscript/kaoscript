extern console
extern class EvalError

import '../export/export.throw.extern.ne.ks'

try {
	foo()
}
on EvalError catch error {
	console.error(error)
}