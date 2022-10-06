const {Helper} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x = null) => {
			return [x];
		}, (fn, ...args) => {
			if(args.length <= 1) {
				return fn.call(this, args[0]);
			}
			throw Helper.badArgs();
		});
	})();
	expect(foo()).to.eql([null]);
	expect(foo(1)).to.eql([1]);
	expect(Helper.function(() => {
		return foo(1, 2);
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(this);
		}
		throw Helper.badArgs();
	})).to.throw();
};