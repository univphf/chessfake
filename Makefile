build:
	dart2native lib/main.dart -o bin/chessfake.exe

build-linux:
	dart2native lib/main.dart -o bin/chessfake

run:
	dart run lib/main.dart

run-exe:
	bin\chessfake.exe