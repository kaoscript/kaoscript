const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isFoobar: value => Type.isDexObject(value, 1, 0, {names: value => Type.isArray(value, Type.isString), type: Type.isString})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		if(values === void 0) {
			values = null;
		}
		let names;
		if((Type.isValue(values) ? (({names} = values), true) : false)) {
			return names;
		}
		return [];
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => __ksType.isFoobar(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};