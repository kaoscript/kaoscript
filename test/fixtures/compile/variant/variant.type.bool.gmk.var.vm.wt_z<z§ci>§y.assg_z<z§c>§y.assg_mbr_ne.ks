enum NodeKind {
	ArrayBinding
	ObjectBinding
	Identifier
}

type NodeData = {
	variant kind: NodeKind {
		ArrayBinding {
			alias: NodeData(Identifier)?
		}
		Identifier {
			name: String
		}
		ObjectBinding {
			alias: NodeData(Identifier)?
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

func fooobar(mut event: Event<NodeData(Identifier, ArrayBinding, ObjectBinding)>(Y)?) {
	event = reqBinding()

	event.value.alias = null
}

func reqBinding(): Event<NodeData(ArrayBinding, ObjectBinding)>(Y) {
	return {
		ok: true
		value: {
			kind: .ArrayBinding
		}
	}
}