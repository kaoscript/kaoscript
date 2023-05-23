const {OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isFoobar: value => Type.isDexObject(value, 1, 0, {parent: value => __ksType.isFoobar(value) || Type.isNull(value)})
	};
	const f1 = new OBJ();
	const f2 = (() => {
		const o = new OBJ();
		o.parent = f1;
		return o;
	})();
};