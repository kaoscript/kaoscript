require class Node

var right = new Node('e')
var root = new Node('root')
	..left = (new Node('a')
		..left = (new Node('b')
			..left = new Node('c')
		)
		..right = new Node('d')
	)
	..right = right