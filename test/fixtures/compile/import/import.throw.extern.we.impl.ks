extern console

import '../export/export.throw.extern.we.impl'

try {
	foo()
}
on SyntaxError catch error {
	console.error(error)
}