extern func reverse(value: Array): Array
extern func reverse(value: Number): Number

func reverse(value: String): String => value.split('').reverse().join('')

export reverse