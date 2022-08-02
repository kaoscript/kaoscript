extern console, JSON

import 'fs'

async func read() {
	var data = await fs.readFile('data.json')

	console.log(data)

	return data
}