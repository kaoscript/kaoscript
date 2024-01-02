type Position = {
	line: Number
	column: Number
}

type Range = {
	start: Position
	end: Position
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

type NodeData = Range & {
	variant kind: NodeKind {
		ExpressionStatement {
			expression: NodeData(Expression)
		}
		UnlessStatement {
			condition: NodeData(Expression)
			whenFalse: NodeData(Block, ExpressionStatement, ReturnStatement)
		}
	}
}

type Event<T> = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: T
			start: Position
			end: Position
		}
	}
}

func foobar(statement: Event<NodeData>(Y)) {
	if statement.value is .UnlessStatement {
		var { condition, whenFalse } = statement.value
	}
}