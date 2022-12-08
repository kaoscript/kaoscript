const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const foo = (() => {
		const d = new OBJ();
		d.bar = "hello";
		d.baz = 3;
		return d;
	})();
	const {bar, baz} = foo;
	console.log(bar, baz + 1);
};