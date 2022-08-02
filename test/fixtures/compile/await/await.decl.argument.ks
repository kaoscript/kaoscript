extern console, JSON

import 'fs'

async func read() {
	var data = JSON.parse(await fs.readFile('data.json'))

	console.log(data)

	return data
}