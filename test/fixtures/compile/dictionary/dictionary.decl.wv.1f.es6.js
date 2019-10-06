var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.bar = function(name = null) {
			if(name !== null && !Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String?'");
			}
			let n = 0;
		};
		return d;
	})();
};