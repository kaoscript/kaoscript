extern console

import '../export/export.throw.extern.we.default.ks'

try {
	foo()
}
on EvalError catch error {
	console.error(error)
}