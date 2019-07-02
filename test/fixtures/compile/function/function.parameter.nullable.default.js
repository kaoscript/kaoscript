var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(array) {
		if(array === void 0 || array === null) {
			array = [];
		}
		else if(!Type.isArray(array)) {
			throw new TypeError("'array' is not of type 'Array'");
		}
	}
	const condition = true;
	const values = [1, 2, 3];
	foobar(condition ? Helper.mapArray(values, function(value) {
		return value;
	}) : null);
};