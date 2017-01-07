class Shape {
	private {
		_color: string = ''
	}
	
	$create(@color: string)
}

#[cc(all(ecma, target_version = '6'))]
impl Shape {
	draw_es6(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

#[cc(all(ecma, target_version = '5'))]
impl Shape {
	draw_es5(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}

#[cc(any(trident, all(safari, target_version = '8')))]
impl Shape {
	draw_trident(canvas): string {
		return `I'm drawing a \(this._color) rectangle.`
	}
}