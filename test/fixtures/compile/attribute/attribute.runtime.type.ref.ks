#![runtime(type(alias='$ksType'))]

func foo(x) {
	if x is Dictionary {
		return $ksType.isEmptyObject(x)
	}
	else {
		return false
	}
}