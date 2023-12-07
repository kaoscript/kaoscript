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

type NodeData = Position & {
	variant kind: NodeKind {
		TypeReference {
			subtypes: NodeData(Identifier)[] | NodeData(Expression) | Null
		}
	}
}

type Event<T> = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: T
			line: Number
			column: Number
		}
	}
}

func foobar(subtypes: Event<Event<NodeData(Identifier)>(Y)[] | NodeData(Expression)>(Y)?, { line, column }: Position): NodeData(TypeReference) {
	var result = {
		kind: NodeKind.TypeReference
		line
		column
	}

	if ?subtypes {
		if subtypes.value is Array {
			result.subtypes = [subtype.value for var subtype in subtypes.value]
		}
		else {
			result.subtypes = subtypes.value
		}
	}

	return result
}