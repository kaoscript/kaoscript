export class URI {
	syntime func register(scheme: String, meta: String = 'hier_part [ "?" query ] [ "#" fragment ]') {
		import 'npm:@kaoscript/test-import/src/index.ks'

		var name = `\(scheme[0].toUpperCase())\(scheme.substr(1).toLowerCase())URI`

		quote {
			class #w(name) extends URI {
				private {
					_e: Number	= #(PI)
				}
			}
		}
	}
}

URI.register('file', '[ "//" [ host ] ] path_absolute')