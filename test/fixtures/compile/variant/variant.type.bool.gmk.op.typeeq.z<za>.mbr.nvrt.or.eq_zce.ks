enum NodeKind {
	Identifier
	ObjectComprehension

	Expression = ObjectComprehension | Identifier
}

type NodeData = {
	variant kind: NodeKind {
		Identifier {
			name: String
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

func foobar(data: Event<NodeData(Expression)>) {
	if !?]data || data.value is .ObjectComprehension {
	}
}