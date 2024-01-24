extern {
	class UIView
	class UIImageView
}

func foobar(view: UIView) {
	match view {
		is UIImageView					=> echo("It's an image view")
	}
}