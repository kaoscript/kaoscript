func foo(lang) {
	var dyn end = ''
	var dyn begin = if lang == 'en' set (end = 'goodbye', 'hello') else 'bonjour'
}