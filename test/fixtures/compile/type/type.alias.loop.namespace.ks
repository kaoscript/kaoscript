type Row = {
	id: Number
	createdAt: Date
	links: Row[]
}

namespace Foobar {
	type Node = {
		name: String
		parent: Node?
		rows: Row[]
	}

	func foobar(data: Node) {
	}
}