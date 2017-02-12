var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(Color, __ks_Color, Space) {
	Helper.newField("_luma", "Number");
	Helper.newInstanceMethod({
		class: Color,
		name: "luma",
		function: function() {
			return this._luma;
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: []
		}
	});
	Helper.newInstanceMethod({
		class: Color,
		name: "luma",
		function: function(luma) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(luma === void 0 || luma === null) {
				throw new TypeError("'luma' is not nullable");
			}
			else if(!Type.isNumber(luma)) {
				throw new TypeError("'luma' is not of type 'Number'");
			}
			return this;
		},
		signature: {
			access: 3,
			min: 1,
			max: 1,
			parameters: [
				{
					type: "Number",
					min: 1,
					max: 1
				}
			]
		}
	});
	return {
		Color: Color,
		Space: Space
	};
}