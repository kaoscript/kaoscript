var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = {
		bar: function(name = null) {
			if(name !== null && !Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			let n = 0;
		}
	};
};