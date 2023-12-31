const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = {};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(lines) {
		let line;
		let __ks_0, __ks_1, __ks_2, __ks_3;
		[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoopBounds(0, "", 0, "lines.length", lines.length, Infinity, "", 1);
		for(let __ks_4 = __ks_0, i; __ks_4 < __ks_1; __ks_4 += __ks_2) {
			i = __ks_3(__ks_4);
			if((line = lines[i].trim()).length !== 0) {
				if(line.startsWith("foobar")) {
				}
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isArray(value, Type.isString);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};