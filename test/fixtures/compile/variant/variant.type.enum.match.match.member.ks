enum NodeKind {
	Block
	ExpressionStatement
	Identifier
	ReturnStatement
	UnlessStatement

	Expression = Identifier
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
}

func foobar(data: NodeData) {
	match data {
		.UnlessStatement {
			match data.whenFalse {
				.ExpressionStatement {
					echo(data.whenFalse.expression)
				}
			}
		}
	}
}