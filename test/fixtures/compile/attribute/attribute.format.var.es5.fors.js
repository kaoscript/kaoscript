module.exports = function() {
	for(var x = 0; x < 10; ++x) {
		console.log(x);
	}
	for(var x = 0; x <= 10; ++x) {
		console.log(x);
	}
	var heroes = ["leto", "duncan", "goku"];
	for(var index = 0, __ks_0 = heroes.length, hero; index < __ks_0; ++index) {
		hero = heroes[index];
		console.log("The hero at index %d is %s", index, hero);
	}
	var likes = {
		leto: "spice",
		paul: "chani",
		duncan: "murbella"
	};
	for(var key in likes) {
		var value = likes[key];
		console.log(key + " likes " + value);
	}
};