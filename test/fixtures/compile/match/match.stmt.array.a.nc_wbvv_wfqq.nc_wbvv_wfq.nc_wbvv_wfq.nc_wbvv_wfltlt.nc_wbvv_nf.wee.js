const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(point) {
		let __ks_0 = Helper.memo(Type.isDexArray(point, 1, 2, 2, Type.isValue));
		if(__ks_0() && (([x, y]) => (x === 0) && (y === 0))(point)) {
			let [x, y] = point;
			console.log("(0, 0) is at the origin");
		}
		else if(__ks_0() && (([x, y]) => y === 0)(point)) {
			let [x, y] = point;
			console.log(Helper.concatString("(", x, ", 0) is on the x-axis"));
		}
		else if(__ks_0() && (([x, y]) => x === 0)(point)) {
			let [x, y] = point;
			console.log(Helper.concatString("(0, ", y, ") is on the y-axis"));
		}
		else if(__ks_0() && (([x, y]) => (Operator.lte(-2, x) && Operator.lte(x, 2)) && (Operator.lte(-2, y) && Operator.lte(y, 2)))(point)) {
			let [x, y] = point;
			console.log(Helper.concatString("(", x, ", ", y, ") is inside the box"));
		}
		else if(__ks_0()) {
			let [x, y] = point;
			console.log(Helper.concatString("(", x, ", ", y, ") is outside of the box"));
		}
		else {
			console.log("Not a point");
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