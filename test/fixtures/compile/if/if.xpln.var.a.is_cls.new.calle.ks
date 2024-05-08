func foobar(clazz) {
	var expression = if clazz is Class set clazz.new() else clazz()
}