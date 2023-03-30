const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(pair) {
		let __ks_0 = Helper.memo(Type.isDexArray(pair, 1, 2, 2, Type.isValue));
		if(__ks_0() && (([x, y]) => x === y)(pair)) {
			let [x, y] = pair;
			console.log("These are twins");
		}
		else if(__ks_0() && (([x, y]) => Operator.add(x, y) === 0)(pair)) {
			let [x, y] = pair;
			console.log("Antimatter, kaboom!");
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