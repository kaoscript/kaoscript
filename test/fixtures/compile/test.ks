// class Foobar {
// 	private {
// 		@x: Number?
// 	}
// 	foobar() {
// 		match @match() {
// 			1 {
// 				@quxbaz(@x)
// 			}
// 			else {
// 			}
// 		}
// 	}
// 	match() => @x <- 0
// 	quxbaz(x: Number) {
// 	}
// }






// enum NodeKind {
// 	ArrayBinding
// 	ObjectBinding
// 	Identifier
// }

// type NodeData = {
// 	variant kind: NodeKind {
// 		ArrayBinding {
// 			alias: NodeData(Identifier)?
// 		}
// 		Identifier {
// 			name: String
// 		}
// 		ObjectBinding {
// 			alias: NodeData(Identifier)?
// 		}
// 	}
// }

// type Event<T> = {
// 	variant ok: Boolean {
// 		false, N {
// 		}
// 		true, Y {
// 			value: T
// 		}
// 	}
// }

// // func fooobar(mut internal: Event<NodeData(Identifier, ArrayBinding, ObjectBinding)>(Y)?) {
// // 	if internal?.value is .Identifier {
// // 		var alias = internal

// // 		internal = reqBinding()

// // 		internal.value.alias = alias.value
// // 	}
// // }
// // func fooobar() {
// // 	var binding = reqBinding()

// // 	binding.value.alias = null
// // }
// // func fooobar(value: NodeData(ArrayBinding, ObjectBinding)) {
// // 	value.alias = null
// // }

// func reqBinding(): Event<NodeData(ArrayBinding, ObjectBinding)>(Y) {
// 	return {
// 		ok: true
// 		value: {
// 			kind: .ArrayBinding
// 		}
// 	}
// }










