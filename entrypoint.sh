#!/bin/bash
cd /src/
# run codeql 
if [ -s cpp-db ];then
	rm -r cpp-db
fi
echo "Install the dependencies for compiling the repository"
apt-get update -yqq
apt-get install -yqq git gcc g++ python pkg-config libssl-dev libdbus-1-dev \
	libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev \
	python3-pip unzip libgirepository1.0-dev libcairo2-dev

export ALLOW_NINJA_ENV=true
source scripts/activate.sh
gn gen out/host
echo "Create the codeql database" 
codeql database create cpp-db --language=cpp --command="ninja -C out/host"
echo "Run the queries to find results"
codeql database analyze -j0 cpp-db /root/codeql-repo/cpp/ql/src/Likely\ Bugs/ \
	/root/codeql-repo/cpp/ql/src/Best\ Practices/ \
	/root/codeql-repo/cpp/ql/src/Critical/ \
	/root/codeql-repo/cpp/ql/src/experimental/ \
	--format=csv --output /src/cpp-results.csv

CWE=$(ls -d /root/codeql-repo/cpp/ql/src/Security/CWE/* | grep -v CWE-020)
codeql database analyze -j0 cpp-db $CWE --format=csv --output /src/cpp-security-results.csv

exit 0
cd examples/shell
gn gen out/debug
ninja -C out/debug



