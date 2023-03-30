const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		return data.x;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isObject(value) && Type.isDexObject(value, 2, 0, {type: Type.isNumber});
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};