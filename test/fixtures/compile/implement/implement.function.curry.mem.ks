func $memoize(hasher: Function?, bind?, self: Function, cache: {}, ...args?) {
}

impl Function {
	memoize(hasher: Function? = null, bind? = null): Function {
		return $memoize^^(hasher, bind, this, {}, ...)
	}
}