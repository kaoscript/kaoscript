const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(test) {
		let value;
		__ks_lbl_0: if(test(0) === true) {
			for(let i = 1; i <= 10; ++i) {
				if(test(i) === true) {
					value = i;
					break __ks_lbl_0;
				}
			}
			console.log("hello");
			value = 1;
		}
		else {
			value = 0;
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