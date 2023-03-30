const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const {foo, bar, qux} = (() => {
		const o = new OBJ();
		o.foo = 2;
		o.qux = 9;
		return o;
	})();
	console.log(foo, bar, qux);
};