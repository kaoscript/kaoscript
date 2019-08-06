set -e

packages=(
	'parser'
	'source-generator'
	'coverage-istanbul'
)

for name in "${packages[@]}"
do
	cd ../${name}

	npm up

	make clean test
done

cd ../../ZokugunKS/lang

packages=(
	'lang'
	'lang.color'
	'lang.color.alvy'
	'lang.math.vector'
	'lang.math.matrix'
	'lang.color.cie'
	'lang.color.xterm'
	'lang.date'
	'lang.timezone'
	'lang.i18n'
	'template'
)

for name in "${packages[@]}"
do
	cd ../${name}

	npm up

	make clean test
done