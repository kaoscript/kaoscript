extern JSON

import 'fs'

async func read() {
	var data = await fs.readFile('data.json')

	return data
}