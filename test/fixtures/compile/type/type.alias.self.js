const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.alias(value => Type.isDexObject(value, 1, 0, {parent: value => Foobar.is(value) || Type.isNull(value)}));
	const f1 = new OBJ();
	const f2 = (() => {
		const o = new OBJ();
		o.parent = f1;
		return o;
	})();
};