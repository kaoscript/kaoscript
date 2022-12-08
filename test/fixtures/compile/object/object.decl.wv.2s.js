const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new OBJ();
		d.bar = "hello";
		d["qux"] = "world";
		return d;
	})();
};