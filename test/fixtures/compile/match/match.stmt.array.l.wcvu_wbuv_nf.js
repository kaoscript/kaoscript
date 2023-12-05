const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(point) {
		if(Type.isDexArray(point, 1, 2, 2) && point[0] === 0 && Type.isDexArray(point, 0, 2, 0, 0, [Type.isValue, Type.isValue])) {
			let [, y] = point;
			console.log(Helper.concatString("(0, ", y, ") is on the y-axis"));
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isArray;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};