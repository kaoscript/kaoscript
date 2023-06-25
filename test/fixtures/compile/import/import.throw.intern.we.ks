extern console

import '../export/export.throw.intern.we.ks'

try {
	foo()
}
on MyError catch error {
	console.error(error)
}