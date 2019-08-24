extern console, JSON

import 'fs'

async func read() {
	const data = JSON.parse(await fs.readFile('data.json'))

	console.log(data)

	return data
}