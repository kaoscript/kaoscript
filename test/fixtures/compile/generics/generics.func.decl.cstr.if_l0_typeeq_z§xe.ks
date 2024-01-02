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

func foobar<T is NodeData>(values: T[]) {
	if values[0] is NodeData(ExpressionStatement) {
	}
}
