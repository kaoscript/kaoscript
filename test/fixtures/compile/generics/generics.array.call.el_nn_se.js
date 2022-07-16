const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_RegExp = {};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const regex = /foo/;
	let match = regex.exec("foobar");
	if(Type.isValue(match)) {
		if(Type.isValue(match[0])) {
			foobar.__ks_0(match[0]);
		}
	}
};