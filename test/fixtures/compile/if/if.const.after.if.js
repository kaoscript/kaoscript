var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		let data = 42;
		if(true) {
			let __ks_data_1 = quxbaz();
			if(Type.isValue(__ks_data_1)) {
				console.log(__ks_data_1);
			}
			console.log(data);
		}
		console.log(data);
	}
	function quxbaz() {
	}
};