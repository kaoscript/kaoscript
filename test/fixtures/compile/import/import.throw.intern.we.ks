extern console

import '../export/export.throw.intern.we'

try {
	foo()
}
on MyError catch error {
	console.error(error)
}