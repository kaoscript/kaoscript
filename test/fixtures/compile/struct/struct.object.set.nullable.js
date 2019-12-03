var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = Helper.struct(function(qux = null) {
		if(qux !== null && !Type.isStructInstance(qux, Quxbaz)) {
			throw new TypeError("'qux' is not of type 'Quxbaz?'");
		}
		const _ = new Dictionary();
		_.qux = qux;
		return _;
	});
	var Quxbaz = Helper.struct(function(x, y) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		const _ = new Dictionary();
		_.x = x;
		_.y = y;
		return _;
	});
	const point = Foobar();
	point.qux = Quxbaz(1, 1);
};