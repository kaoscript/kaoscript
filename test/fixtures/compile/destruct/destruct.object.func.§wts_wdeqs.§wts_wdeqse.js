const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(__ks_0) {
		let x = Helper.default(__ks_0.x, 1, () => "foo"), y = Helper.default(__ks_0.y, 1, () => "bar");
		console.log(Helper.concatString(x, ".", y));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isDexObject(value, 1, 0, {x: value => Type.isString(value) || Type.isNull(value), y: value => Type.isString(value) || Type.isNull(value)});
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};