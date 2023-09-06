func $wrap(this, self, ...args?) {
}

impl Function {
	wrap(): Function {
		return $wrap^^(this, ...)
	}
}