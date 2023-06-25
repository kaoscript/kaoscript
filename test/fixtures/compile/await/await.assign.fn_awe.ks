extern JSON

import 'node:fs'

async func read() {
	var mut data = null

	data = await fs.readFile('data.json')

	return data
}