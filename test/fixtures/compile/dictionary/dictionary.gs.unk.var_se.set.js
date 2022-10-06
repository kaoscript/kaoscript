const {Dictionary} = require("@kaoscript/runtime");
module.exports = function() {
	const o = (() => {
		const d = new Dictionary();
		d.name = "White";
		return d;
	})();
	o.root = o;
	console.log(o.root.name);
};