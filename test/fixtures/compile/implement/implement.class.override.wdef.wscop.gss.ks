func defaultMessage(): String => 'Hello!'

class Shape {
	draw(text: String = defaultMessage()): String => text
}

export Shape