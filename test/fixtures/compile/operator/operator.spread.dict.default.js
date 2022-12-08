const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const original = (() => {
		const d = new OBJ();
		d.a = 1;
		d.b = 2;
		return d;
	})();
	const copy = Helper.newObject(-1, original, 1, "c", 3);
};