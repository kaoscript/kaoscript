const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		let z, __ks_0;
		let y;
		if(data() === true) {
			y = 0;
		}
		else if(Type.isValue(__ks_0 = data()) ? (z = __ks_0, true) : false) {
			y = 0;
		}
		else {
			y = 0;
		}
		let x;
		if((Type.isValue(__ks_0 = data()) ? (x = __ks_0, true) : false)) {
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