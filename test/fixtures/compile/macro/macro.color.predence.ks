extern t1, t2, t3, h, i

const foo = t1 + (t2 - t1) * (2 / 3 - t3) * 6
const bar = h + 1 / 3 * - (i - 1)

export class Color {
	macro registerSpace(@expression: Object) {
		macro Color.registerSpace(#(expression))
	}
}

Color.registerSpace!({
	name: 'FBQ'
	formatters: {
		foo(t1, t2, t3) => t1 + (t2 - t1) * (2 / 3 - t3) * 6
		bar(h, i) => h + 1 / 3 * - (i - 1)
	}
})