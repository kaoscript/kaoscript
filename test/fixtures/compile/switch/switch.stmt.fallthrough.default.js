const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(d) {
		let __ks_0 = () => {
			console.log("hour");
			__ks_1();
		};
		let __ks_1 = () => {
			console.log("minute");
			__ks_2();
		};
		let __ks_2 = () => {
			console.log("second");
		};
		if(d === "hour") {
			__ks_0();
		}
		else if(d === "minute") {
			__ks_1();
		}
		else if(d === "second") {
			__ks_2();
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