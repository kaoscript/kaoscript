const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new OBJ();
		d.bar = (() => {
			const d = new OBJ();
			d.n1 = "hello";
			d.n2 = "world";
			return d;
		})();
		return d;
	})();
	let {bar: {n1, n2: qux}} = foo;
	console.log(n1, qux);
};