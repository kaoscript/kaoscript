const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(value === void 0) {
			value = null;
		}
		if(Type.isNumber(value)) {
		}
		else if(Type.isArray(value) && Type.isDexArray(value, 0, 1, 0, Type.isValue, [Type.isNumber]) && (([argument, ...__ks_arguments_1]) => argument > 0)(value)) {
			let [argument, ...__ks_arguments_1] = value;
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};