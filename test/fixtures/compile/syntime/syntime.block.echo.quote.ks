syntime func myMacro() {
	quote {
		func foobar() {
		}
	}
}

syntime {
	var ast = myMacro()

	echo(quote #(ast))
}