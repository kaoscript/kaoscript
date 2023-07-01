const {Helper} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((x) => {
			if(x === void 0) {
				x = null;
			}
			return [x];
		}, (that, fn, ...args) => {
			if(args.length === 1) {
				return fn.call(null, args[0]);
			}
			throw Helper.badArgs();
		});
	})();
	expect(Helper.function(() => {
		return foo();
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo(1)).to.eql([1]);
	expect(foo(null)).to.eql([null]);
	expect(Helper.function(() => {
		return foo(1, 2);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
};