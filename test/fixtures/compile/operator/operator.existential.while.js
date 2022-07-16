const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_RegExp = {};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(text, pattern) {
		let founds = [];
		let data = null;
		let __ks_0;
		while(Type.isValue(__ks_0 = pattern.exec(text)) ? (data = __ks_0, true) : false) {
			founds.push(data);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isRegExp;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};