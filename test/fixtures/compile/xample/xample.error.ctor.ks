extern sealed class Error

export class Exception extends Error {
	public {
		fileName: String?		= null
		lineNumber: Number		= 0
		message: String
		name: String
	}

	constructor(@message) { // {{{
		super()

		@name = this.constructor.name
	} // }}}

	constructor(@message, @fileName, @lineNumber) { // {{{
		this(message)
	} // }}}

	constructor(@message, node: AbstractNode) { // {{{
		this(message, node.file(), node._data.start.line)
	} // }}}
}

abstract class AbstractNode {
	private {
		_data
		_parent: AbstractNode?	= null
	}
	file() => @parent?.file()
}