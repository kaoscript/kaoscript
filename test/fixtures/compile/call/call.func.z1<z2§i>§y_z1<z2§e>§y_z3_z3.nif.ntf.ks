type Position = {
	line: Number
	column: Number
}

type Range = {
	start: Position
	end: Position
}

enum NodeKind {
	ArrayBinding
	ObjectBinding
	Identifier

	Expression = ArrayBinding | ObjectBinding | Identifier
}

type NodeData = {
	variant kind: NodeKind {
		Identifier {
			name: String
		}
	}
}

type Event<T> = Range & {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: T
		}
	}
}

func foobar(name: Event<NodeData(Expression)>(Y), value: Event<NodeData(Expression)>(Y)) {
	quxbaz(name, value, name, value)
}

func quxbaz(
	name: Event<NodeData(Identifier)>(Y)
	value: Event<NodeData(Expression)>(Y)
	{ start }: Range
	{ end }: Range
) {
}