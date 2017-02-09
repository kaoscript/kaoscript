extern console

func $format(message: String) => message.toUpperCase()

class LetterBox {
	private {
		_messages: Array<String>
	}
	
	constructor(@messages)
	
	build_01() => this._messages.map(message => this.format(message))
	
	build_02() => this._messages.map((message, foo = 42, bar) => this.format(message))
	
	build_03() => this._messages.map((message, foo = null, bar) => this.format(message))
	
	build_04() => this._messages.map((message, ...foo, bar) => this.format(message))
	
	build_05() => this._messages.map((message, ...foo, bar) => $format(message))
	
	static compose_00(box) => box._messages.map(message => box.format(message))
	
	static compose_01(box) => box._messages.map((message, ...foo, bar) => box.format(message))
	
	format(message: String) => message.toUpperCase()
}