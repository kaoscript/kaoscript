namespace ModuleA {
	namespace ModuleB {
		export func foobar(): String {
			return 'foobar'
		}
	}

	export ModuleB for foobar
}

echo(`\(ModuleA.foobar())`)