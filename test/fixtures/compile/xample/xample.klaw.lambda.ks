extern __dirname, klaw, path, prepare

for file in klaw(path.join(__dirname, 'fixtures'), {
	nodir: true
	traverseAll: true
	filter: item => item.path.slice(-5) == '.json'
}) {
	prepare(file.path)
}