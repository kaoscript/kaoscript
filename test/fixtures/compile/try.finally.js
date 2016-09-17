module.exports = function() {
	let __ks_0 = () => {
		console.log("finally");
	};
	try {
		console.log("foobar");
		__ks_0();
	}
	catch(__ks_1) {
		__ks_0();
	}
}