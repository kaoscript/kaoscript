type Event = {
	variant ok: Boolean {
		false {
		}
		true {
			value: String
		}
	}
}

func foobar(): Event => { ok: false }

func quxbaz() {
	var mut value = null

	if (value <- foobar()).ok {
		echo(`\(value.value)`)
	}
}