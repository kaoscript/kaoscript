extern JSON

import 'fs'

async func read() {
	var mut data = null

	data = await fs.readFile('data.json')

	return data
}