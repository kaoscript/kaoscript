#![libstd(package='./libstd.smth.wimpl.decl.ks')]

impl Object<V, K> {
	static {
		key(object: Object<V, K>, index: Number): K? {
			var mut i = 0

			for var _, key of object {
				if i == index {
					return key
				}

				i += 1
			}

			return null
		}
	}
}

export *