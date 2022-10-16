type BS = Boolean | String

func foobar(props: Boolean{}, key: String, value: BS) {
	props[key] &&= value
}