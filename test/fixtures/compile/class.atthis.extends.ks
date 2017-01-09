extern console

class Shape {
	private {
		_color: string
	}
	
	$create(@color)
	
	draw(): string {
	}
}

class Rectangle extends Shape {
	$create(color) {
		super(color)
	}
	
	draw() {
		return 'I\'m drawing a ' + @color + ' rectangle.'
	}
}

let r = new Rectangle('black')

console.log(r.draw())