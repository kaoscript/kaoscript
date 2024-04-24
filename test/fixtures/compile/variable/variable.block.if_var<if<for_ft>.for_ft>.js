const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		let d, __ks_0;
		if((Type.isValue(__ks_0 = data()) ? (d = __ks_0, true) : false)) {
			if(Operator.lt(data.left, data.min)) {
				let __ks_1, __ks_2, __ks_3;
				[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoopBounds(0, "", 1, "data.min", data.min, Infinity, "", 1);
				for(let __ks_4 = __ks_0, i; __ks_4 <= __ks_1; __ks_4 += __ks_2) {
					i = __ks_3(__ks_4);
				}
			}
			let __ks_1, __ks_2, __ks_3;
			[__ks_0, __ks_1, __ks_2, __ks_3] = Helper.assertLoopBounds(0, "", 1, "data.min", data.min, Infinity, "", 1);
			for(let __ks_4 = __ks_0, i; __ks_4 <= __ks_1; __ks_4 += __ks_2) {
				i = __ks_3(__ks_4);
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};