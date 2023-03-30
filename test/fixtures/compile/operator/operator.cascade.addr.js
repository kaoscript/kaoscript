module.exports = function(getAddress) {
	let __ks_0;
	__ks_0 = getAddress();
	__ks_0.setStreet("Elm", "13a");
	__ks_0.city = "Carthage";
	__ks_0.state = "Eurasia";
	__ks_0.zip(66666, 6666);
};