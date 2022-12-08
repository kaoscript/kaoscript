const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const o = (() => {
		const d = new OBJ();
		d.name = "White";
		return d;
	})();
	o.root = o;
	console.log(o.root.name);
};