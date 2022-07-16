const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function age() {
		return age.__ks_rt(this, arguments);
	};
	age.__ks_0 = function() {
		return 15;
	};
	age.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return age.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function main() {
		return main.__ks_rt(this, arguments);
	};
	main.__ks_0 = function() {
		let __ks_0 = age.__ks_0();
		if(__ks_0 === 0) {
			console.log("I'm not born yet I guess");
		}
		else if(__ks_0 >= 1 && __ks_0 <= 12) {
			let n = __ks_0;
			console.log(Helper.concatString("I'm a child of age ", n));
		}
		else if(__ks_0 >= 13 && __ks_0 <= 19) {
			let n = __ks_0;
			console.log(Helper.concatString("I'm a teen of age ", n));
		}
		else {
			let n = __ks_0;
			console.log(Helper.concatString("I'm an old person of age ", n));
		}
	};
	main.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return main.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};