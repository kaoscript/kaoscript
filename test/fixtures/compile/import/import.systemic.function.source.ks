import '../_/_function.ks'

export class Template {
	compile(): Function {
		return () => 42
	}
	run(...args) {
	}
}

export const template = new Template()