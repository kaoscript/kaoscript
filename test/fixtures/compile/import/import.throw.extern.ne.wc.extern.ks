extern console
extern class SyntaxError

import '../export/export.throw.extern.ne.ks'

try {
	foo()
}
on SyntaxError catch error {
	console.error(error)
}