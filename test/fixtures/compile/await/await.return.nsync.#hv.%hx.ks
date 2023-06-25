import 'node:fs'

func read(): Void {
	var data = await fs.readFile('data.json')
}