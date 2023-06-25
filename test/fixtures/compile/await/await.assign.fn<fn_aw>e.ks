extern JSON

import 'node:fs'

async func read() {
	var mut data = null

	data = JSON.parse(await fs.readFile('data.json'))

	return data
}