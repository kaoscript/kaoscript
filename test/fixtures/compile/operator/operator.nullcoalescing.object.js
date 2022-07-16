const {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foobar = Type.isValue(x.y) ? x.y : (() => {
		const d = new Dictionary();
		d.x = 42;
		return d;
	})();
};