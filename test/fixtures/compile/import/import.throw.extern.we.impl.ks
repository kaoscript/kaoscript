extern console

import '../export/export.throw.extern.we.impl.ks'

try {
	foo()
}
on EvalError catch error {
	console.error(error)
}