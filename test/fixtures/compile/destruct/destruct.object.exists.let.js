const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const foo = (() => {
		const d = new OBJ();
		d.bar = "hello";
		d.baz = 3;
		return d;
	})();
	let bar = "foo";
	let baz;
	({bar, baz} = foo);
	console.log(bar, baz);
};