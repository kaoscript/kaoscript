const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let foo = (() => {
		return Helper.function((items) => {
			return [items];
		}, (that, fn, ...args) => {
			const t0 = Type.isString;
			const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
			let pts;
			if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
				return fn.call(null, Helper.getVarargs(args, 0, pts[1]));
			}
			throw Helper.badArgs();
		});
	})();
	expect(foo()).to.eql([[]]);
	expect(Helper.function(() => {
		return foo(1);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo(null);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo(true);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo")).to.eql([["foo"]]);
	expect(Helper.function(() => {
		return foo("true", 1);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo("true", true);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(Helper.function(() => {
		return foo("true", null);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
	expect(foo("foo", "bar", "qux")).to.eql([["foo", "bar", "qux"]]);
	expect(Helper.function(() => {
		return foo("foo", "bar", "qux", 4);
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	})).to.throw();
};