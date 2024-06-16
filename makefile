./build/opm.exe: ./src/main.odin
	odin build src -out:build/opm.exe -debug
