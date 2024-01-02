extern {
	JSON
}

import {
	'../variant/variant.type.enum.export.nfusion.ks'
}

func prepare(content) {
	var node = JSON.parse(content):>(NodeData)
}