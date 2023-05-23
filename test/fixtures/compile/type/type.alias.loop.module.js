const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isNode: value => Type.isDexObject(value, 1, 0, {name: Type.isString, parent: value => __ksType.isNode(value) || Type.isNull(value)})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isNode;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};