import * from './class.alien.default.ks'

class ClassD extends ClassB {
	private {
		_w: Number	= 0
	}
	constructor(x: Number, y: Number) {
		super(x, y)
		
		@w = @z * @z
	}
}