type BS = Boolean | String

func foobar(props: BS{}, key: String, value: BS) {
	props[key] ^^= value
}