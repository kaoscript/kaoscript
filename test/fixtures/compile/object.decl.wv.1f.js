var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let foo = {
		bar(name = null) {
			if(name !== null && !Type.isString(name)) {
				throw new Error("Invalid type for parameter 'name'");
			}
			let n = 0;
		}
	};
}