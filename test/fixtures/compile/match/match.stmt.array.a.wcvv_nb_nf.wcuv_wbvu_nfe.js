const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(point) {
		let __ks_0 = Helper.memo(Type.isDexArray(point, 1, 2, 2));
		if(__ks_0() && point[0] === 0 && point[1] === 0) {
			console.log("(0, 0) is at the origin");
		}
		else if(__ks_0() && point[1] === 0 && Type.isDexArray(point, 0, 2, 0, 0, [Type.isValue, Type.isValue])) {
			let [x] = point;
			console.log(Helper.concatString("(", x, ", 0) is on the x-axis"));
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