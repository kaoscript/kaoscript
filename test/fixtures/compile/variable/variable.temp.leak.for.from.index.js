module.exports = function() {
	function foo(...args) {
		let i = 42;
		let __ks_0;
		for(i = 0, __ks_0 = args.length; i < __ks_0; ++i) {
			console.log(args[i]);
		}
	}
};