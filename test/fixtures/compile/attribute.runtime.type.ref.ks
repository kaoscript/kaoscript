#![runtime(type(alias='$ksType'))]

func foo(x) {
	if x is Object {
		return $ksType.isEmptyObject(x)
	}
	else {
		return false
	}
}