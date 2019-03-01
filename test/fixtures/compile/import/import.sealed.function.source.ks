import '../_/_function.ks'

export class Template {
	compile(): Function {
		return () => 42
	}
}

export const template = new Template()