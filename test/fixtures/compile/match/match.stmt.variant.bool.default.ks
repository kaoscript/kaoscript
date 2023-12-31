type Event = {
	variant ok: Boolean {
		false {
			message: String
		}
		true {
			value: String
		}
	}
}

func foobar(x: Event) {
	match x {
		true {
			echo(`\(x.value)`)
		}
		false {
		}
	}
}