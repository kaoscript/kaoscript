const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const foo = (() => {
		const o = new OBJ();
		o.bar = 1;
		o.baz = 3;
		return o;
	})();
	const {bar, baz} = foo;
	console.log(bar + baz, baz + 1);
};