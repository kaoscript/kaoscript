func rewire(option) {
	let files = []
	
	for item in option.split(',') {
		item = item.split('=')
		
		files.push({
			input: item[0]
			output: item[1]
		})
	}
	
	return files
}