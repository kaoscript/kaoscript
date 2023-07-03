func rewire(option) {
	var dyn files = []

	for var mut item in option.split(',') {
		item = item.split('=')

		files.push({
			input: item[0]
			output: item[1]
		})
	}

	return files
}