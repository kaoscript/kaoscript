class Message {
	static build(...lines): String => lines.join('\n')
}

const hello = Message.build^^('Hello!')

func print(name: String, printer: func) => printer('It\'s nice to meet you, ', name, '.')

print('miss White', hello)