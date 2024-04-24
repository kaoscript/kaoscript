#![libstd(off)]

import '../_/_string.wstd.ks'
import 'node:child_process' for exec

var df_regex = /([\/[a-z0-9\-\_\s]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+(\/.*)/i

async func disks() {
	var result = []
	var stdout: string, stderr = await exec('df -k')

	for var line in stdout.lines() {
		if var matches ?= df_regex.exec(line) {
			result.push({
				device: matches[1]!?.trim()
				mount: matches[9]
				total: matches[2]!?.toInt() * 1024
				used: matches[3]!?.toInt() * 1024
				available: matches[4]!?.toInt() * 1024
			})
		}
	}

	return result
}

export disks