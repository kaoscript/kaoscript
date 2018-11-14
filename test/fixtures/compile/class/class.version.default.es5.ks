#![format(classes='es5', functions='es5')]

extern console

class Rectangle@1.0.0 {
    private {
    	_color: String
    }
    
    constructor(@color = 'black')

    draw(canvas) {
        return `I'm drawing a \(@color) rectangle.`
    }
}

console.log(Rectangle.name)
console.log(Rectangle.version)