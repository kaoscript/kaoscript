type Position = {
	line: Number
	column: Number
}

enum NodeKind {
	Identifier
	RegularExpression
	TypeReference

	Expression = Identifier | RegularExpression
}

type NodeData = {
	variant kind: NodeKind {
		TypeReference {
			subtypes: NodeData(Identifier)[] | NodeData(Expression) | Null
		}
	}
}

export *