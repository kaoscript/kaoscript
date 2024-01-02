enum NodeKind {
	Block
	ExpressionStatement
	Identifier
	ReturnStatement
	UnlessStatement

	Expression = Identifier
	Statement = ExpressionStatement | ReturnStatement | UnlessStatement
}

type NodeData = {
	variant kind: NodeKind {
		ExpressionStatement {
			expression: NodeData(Expression)
		}
	}
}

type Event<T> = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: T
		}
	}
}

func foobar(): Event<NodeData(Statement)>(Y) {
	return {
		ok: true
		value: {
			kind: NodeKind.ExpressionStatement
			expression: {
				kind: NodeKind.Identifier
			}
		}
	}
}