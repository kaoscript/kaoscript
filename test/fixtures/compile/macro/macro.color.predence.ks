extern t1: Number, t2: Number, t3: Number, h: Number, i: Number

const foo = t1 + (t2 - t1) * (2 / 3 - t3) * 6
const bar = h + 1 / 3 * - (i - 1)

export class Color {
	macro registerSpace(@expression: Object) {
		macro Color.registerSpace(#(expression))
	}
	static registerSpace(data)
}

Color.registerSpace!({
	name: 'FBQ'
	formatters: {
		foo(t1: Number, t2: Number, t3: Number) => t1 + (t2 - t1) * (2 / 3 - t3) * 6
		bar(h: Number, i: Number) => h + 1 / 3 * - (i - 1)
	}
})