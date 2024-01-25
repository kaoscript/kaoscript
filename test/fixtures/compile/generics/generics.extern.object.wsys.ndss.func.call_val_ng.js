const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Object = {};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(object) {
		return Object.keys(object);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};