type Event = {
	variant ok: Boolean {
		false {
			message: String?
		}
		true {
			value: String
		}
	}
}

func foobar() {
	match var x = loadEvent() {
		true {
			echo(`\(x.value)`)
		}
		false {
		}
	}
}

func loadEvent(): Event => { ok: false }