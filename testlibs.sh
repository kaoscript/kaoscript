set -e

cd ../parser
npm up
make clean test

cd ../source-generator
npm up
make clean test

cd ../coverage-istanbul
npm up
make clean test

cd ../../ZokugunKS/lang
npm up
make clean test

cd ../lang.color
npm up
make clean test

cd ../lang.color.alvy
npm up
make clean test

cd ../lang.math.vector
npm up
make clean test