class Color {

}

export class Shape {
	private {
		late _color: Color
		late _name: String
	}
	constructor()
	constructor(@name)
	constructor(@name, @color)
	color() => @color
	color(@color) => this
	name() => @name
	name(@name) => this
}