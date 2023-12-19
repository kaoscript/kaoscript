const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, 0, "Red", 0, "Green", 1, "Blue", 2);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		for(let __ks_1 = 0, __ks_0 = data.length, kind; __ks_1 < __ks_0; ++__ks_1) {
			Helper.assertDexObject(data[__ks_1], 1, 0, {kind: Type.isValue});
			({kind} = data[__ks_1]);
			if(Color(kind) === Color.Red) {
				console.log("red");
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