extern t1: Number, t2: Number, t3: Number, h: Number, i: Number

var foo = t1 + (t2 - t1) * (2 / 3 - t3) * 6
var bar = h + 1 / 3 * - (i - 1)

export class Color {
	macro registerSpace(@expression: Object) {
		macro Color.addSpace(#(expression))
	}
	static addSpace(data)
}

Color.registerSpace({
	name: 'FBQ'
	formatters: {
		foo: func(t1: Number, t2: Number, t3: Number) => t1 + (t2 - t1) * (2 / 3 - t3) * 6
		bar: func(h: Number, i: Number) => h + 1 / 3 * - (i - 1)
	}
})