extern JSON

import 'node:fs'

async func read() {
	var data = await fs.readFile('data.json')

	return data
}