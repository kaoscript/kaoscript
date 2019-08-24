extern console, JSON

import 'fs'

async func read() {
	const data = await fs.readFile('data.json')

	console.log(data)

	return data
}