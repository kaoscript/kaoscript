export namespace NS2 {
	syntime func myMacro() {
		quote {
			func foobar() {
			}
		}
	}

	myMacro()

	export *
}