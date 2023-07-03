extern __dirname, klaw, path, prepare

for var file in klaw(path.join(__dirname, 'fixtures'), {
	nodir: true
	traverseAll: true
	filter: func(item) {
		return item.path.slice(-5) == '.json'
	}
}) {
	prepare(file.path)
}