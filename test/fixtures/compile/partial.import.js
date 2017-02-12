require("kaoscript/register");
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var Shape = require("./export.class.ks")().Shape;
	Helper.newInstanceMethod({
		class: Shape,
		name: "draw",
		function: function(canvas) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(canvas === void 0 || canvas === null) {
				throw new TypeError("'canvas' is not nullable");
			}
			return "I'm drawing a " + this._color + " rectangle.";
		},
		signature: {
			access: 3,
			min: 1,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 1,
					max: 1
				}
			]
		}
	});
}