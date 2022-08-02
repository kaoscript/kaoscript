func foo(lang) {
	var dyn end = ''
	var dyn begin = lang == 'en' ? (end = 'goodbye', 'hello') : 'bonjour'
}