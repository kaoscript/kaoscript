const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(test) {
		if(test === void 0) {
			test = null;
		}
		const x = (test === true) ? 0 : 1;
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isBoolean(value) || Type.isNumber(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};