const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		let __ks_0 = ({foo}) => foo === 1;
		let __ks_1 = ({qux}) => !Type.isNull(qux);
		let __ks_2 = ({foo}) => foo === 1;
		let __ks_3 = ({foo}) => !Type.isNull(foo);
		let __ks_4 = ({qux}) => !Type.isNull(qux);
		if(__ks_0(value) && __ks_1(value)) {
			let {qux: n} = value;
			console.log(Helper.concatString("qux: ", n));
		}
		else if(__ks_2(value)) {
			console.log("foo: 1");
		}
		else if(__ks_3(value)) {
			console.log("has foo");
		}
		else if(__ks_4(value)) {
			console.log("has qux");
		}
		else if(value.bar() === 0) {
			console.log("bar() == 0");
		}
		else {
			console.log("oops!");
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};