type Position = {
	line: Number
	column: Number
}

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
		UnlessStatement {
			condition: NodeData(Expression)
			whenFalse: NodeData(Block, ExpressionStatement, ReturnStatement)
		}
	}
	start: Position
	end: Position
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

func foobar(statement: Event<NodeData>(Y)) {
	if statement.value is .UnlessStatement {
		var { condition, whenFalse } = statement.value
	}
}