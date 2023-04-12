require class Node

var right = Node.new('e')
var root = Node.new('root')
	..left = (Node.new('a')
		..left = (Node.new('b')
			..left = Node.new('c')
		)
		..right = Node.new('d')
	)
	..right = right