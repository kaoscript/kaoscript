require("kaoscript/register");
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var Shape = require("./export.class.ks")().Shape;
	Helper.newInstanceMethod({
		class: Shape,
		name: "draw",
		function: function(canvas) {
			if(canvas === undefined || canvas === null) {
				throw new Error("Missing parameter 'canvas'");
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