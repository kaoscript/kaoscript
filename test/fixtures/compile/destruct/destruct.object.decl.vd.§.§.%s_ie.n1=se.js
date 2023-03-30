const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const foo = (() => {
		const o = new OBJ();
		o.bar = "hello";
		o.baz = 3;
		return o;
	})();
	let {bar, baz} = foo;
	bar = "foo";
	console.log(bar, baz);
};