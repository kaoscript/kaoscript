const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value, type) {
		if(value === void 0) {
			value = null;
		}
		if(!Type.isValue(value)) {
			return;
		}
		if(!Type.isValue(value.type)) {
			console.log(Helper.toString(value.type));
		}
		else {
			value.type = type;
			console.log(value.type);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 2) {
			if(t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};