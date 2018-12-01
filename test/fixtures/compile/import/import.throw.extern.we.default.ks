extern console

import '../export/export.throw.extern.we.default'

try {
	foo()
}
on SyntaxError catch error {
	console.error(error)
}