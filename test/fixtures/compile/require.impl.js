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
			parameters: [
			]
		}
	});
	Helper.newInstanceMethod({
		class: Color,
		name: "luma",
		function: function(luma) {
			if(luma === undefined || luma === null) {
				throw new Error("Missing parameter 'luma'");
			}
			if(!Type.isNumber(luma)) {
				throw new Error("Invalid type for parameter 'luma'");
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