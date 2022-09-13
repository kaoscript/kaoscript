const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function open() {
		return open.__ks_rt(this, arguments);
	};
	open.__ks_0 = function() {
		return 0;
	};
	open.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return open.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function read() {
		return read.__ks_rt(this, arguments);
	};
	read.__ks_0 = function(id) {
		return "";
	};
	read.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return read.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function close() {
		return close.__ks_rt(this, arguments);
	};
	close.__ks_0 = function(id) {
	};
	close.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return close.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		let file = open.__ks_0();
		let __ks_0 = read.__ks_0(file);
		close.__ks_0(file);
		return __ks_0;
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};