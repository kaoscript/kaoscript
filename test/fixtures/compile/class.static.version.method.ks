extern console

class Rectangle {
	public static version() => '1.0.0'
	
    private {
    	_color: String
    }
    
    Rectangle(@color = 'black')

    draw(canvas) {
        return `I'm drawing a \(@color) rectangle.`
    }
}

console.log(Rectangle.name)
console.log(Rectangle.version)