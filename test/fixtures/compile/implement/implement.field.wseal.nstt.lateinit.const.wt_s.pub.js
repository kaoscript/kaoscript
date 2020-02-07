module.exports = function(expect) {
	var __ks_Date = {};
	const d = new Date();
	expect(d.culture).to.not.exist;
	return {
		Date: Date,
		__ks_Date: __ks_Date
	};
};