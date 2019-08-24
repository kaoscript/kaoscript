var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(x, y, z, d) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		if(z === void 0) {
			z = null;
		}
		else if(z !== null && !Type.isString(z)) {
			throw new TypeError("'z' is not of type 'String?'");
		}
		if(d === void 0 || d === null) {
			d = "";
		}
		else if(!Type.isString(d)) {
			throw new TypeError("'d' is not of type 'String'");
		}
	}
	function corge(metadatas) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(metadatas === void 0 || metadatas === null) {
			throw new TypeError("'metadatas' is not nullable");
		}
		let name;
		for(name in metadatas) {
			let data = metadatas[name];
			foobar(data.x, data.y, null, name);
		}
	}
};