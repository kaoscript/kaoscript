const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const original = (() => {
		const o = new OBJ();
		o.a = 1;
		o.b = 2;
		return o;
	})();
	const copy = (() => {
		const o = new OBJ();
		Helper.concatObject(o, original);
		o.c = 3;
		return o;
	})();
};