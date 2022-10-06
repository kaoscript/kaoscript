const {Helper} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = Helper.function(function(x = null) {
		return [x];
	}, (fn, ...args) => {
		if(args.length <= 1) {
			return fn.call(null, args[0]);
		}
		throw Helper.badArgs();
	});
	expect(foo.__ks_0()).to.eql([null]);
	expect(foo.__ks_0(1)).to.eql([1]);
};