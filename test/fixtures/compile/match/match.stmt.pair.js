const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(pair) {
		let __ks_0 = Type.isArray(pair);
		let __ks_1 = ([x, y]) => x === y;
		let __ks_2 = ([x, y]) => Operator.add(x, y) === 0;
		let __ks_3 = ([x, ]) => Operator.modulo(x, 2) === 1;
		if(__ks_0 && pair.length === 2 && __ks_1(pair)) {
			let [x, y] = pair;
			console.log("These are twins");
		}
		else if(__ks_0 && pair.length === 2 && __ks_2(pair)) {
			let [x, y] = pair;
			console.log("Antimatter, kaboom!");
		}
		else if(__ks_0 && pair.length === 2 && __ks_3(pair)) {
			let [x, ] = pair;
			console.log("The first one is odd");
		}
		else {
			console.log("No correlation...");
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