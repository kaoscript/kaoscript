extern console

import '../export/export.throw.extern.we.impl.ks'

try {
	foo()
}
on SyntaxError catch error {
	console.error(error)
}