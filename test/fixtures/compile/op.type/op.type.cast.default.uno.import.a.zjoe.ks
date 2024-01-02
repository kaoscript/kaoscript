extern {
	JSON
}

import {
	'../variant/variant.type.enum.export.wfusion.ks'
}

func prepare(content) {
	var node = JSON.parse(content):>(NodeData)
}