extern {
	class UIView
	class UIImageView
}

func foobar(view: UIView) {
	match view {
		UIImageView					=> echo("It's an image view")
	}
}