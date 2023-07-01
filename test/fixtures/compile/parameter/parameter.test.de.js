const {Helper} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = Helper.function(function(x) {
		if(x === void 0 || x === null) {
			x = 42;
		}
		return [x];
	}, (that, fn, ...args) => {
		if(args.length <= 1) {
			return fn.call(null, args[0]);
		}
		throw Helper.badArgs();
	});
	expect(foo.__ks_0()).to.eql([42]);
	expect(foo.__ks_0(1)).to.eql([1]);
};