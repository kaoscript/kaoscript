extern setTimeout: func

impl Function {
	delay(time, ...args, *bind? = null) => setTimeout(this^$(bind, ...args), time)
}