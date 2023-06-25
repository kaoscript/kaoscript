extern JSON

import 'node:fs'

async func read() {
	var data = JSON.parse(await fs.readFile('data.json'))

	return data
}