const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(pair) {
		if(Type.isDexArray(pair, 1, 2, 0, 0, [Type.isValue, Type.isValue]) && (([x, y]) => x === y)(pair)) {
			let [x, y] = pair;
			console.log("These are twins");
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