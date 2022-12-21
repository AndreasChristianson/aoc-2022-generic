all: make_day1 make_day2 make_day1_gps make_day3 make_day4 make_day5 make_day6 make_day7 make_day8 make_day9 make_day10 make_day11 make_day12 make_day13 make_day14 make_day15 make_day16 make_day17 make_day18 make_day20 make_day21

.PHONY: make_day1
make_day1:
	cd day1;     \
	npm i;       \
	npm start;

.PHONY: make_day1_gps
make_day1_gps:
	echo "https://aoc.meilisearch.com/"; \
	cd day1-gps;                         \
	npm i;                               \
	npm start;
  
.PHONY: make_day2
make_day2:
	cd day2/aoc-2022-day2;                                              \
	mvn package;                                                        \
	java -cp target/aoc-2022-day2-1.0-SNAPSHOT.jar com.pessimistic.App;

.PHONY: make_day3
make_day3:
	cd day3;                                                         \
	mvn package;                                                     \
	kotlin -cp target/day3-1.0-SNAPSHOT.jar com.pessimistic.HelloKt;

.PHONY: make_day4
make_day4:
	cd day4;       \
	python aoc.py;

.PHONY: make_day5
make_day5:
	cd day5;    \
	make run;

.PHONY: make_day6
make_day6:
	cd day6; \
	sbt run

.PHONY: make_day7
make_day7:
	cd day7;   \
	mvn test;

.PHONY: make_day8
make_day8:
	cd day8;               \
	ruby lib/part1.rb;     \
	ruby lib/part2.rb;

.PHONY: make_day9
make_day9:
	cd day9;   \
	cargo run;

.PHONY: make_day10
make_day10:
	cd day10;   \
	deno run --allow-read  main.ts;

.PHONY: make_day11
make_day11:
	cd day11;   \
	julia src/day11.jl;

.PHONY: make_day12
make_day12:
	cd day12;   \
	dotnet run;

.PHONY: make_day13
make_day13:
	cd day13;   \
	elixir day13.exs;

.PHONY: make_day14
make_day14:
	cd day14;   \
	go run sand.go;

.PHONY: make_day15
make_day15:
	cd day15;   \
	lua day15.lua input.txt 2000000 3000000 4000000;

.PHONY: make_day16
make_day16:
	echo "swift sucks";

.PHONY: make_day17
make_day17:
	cd day17;  \
	dart run;

.PHONY: make_day18
make_day18:
	cd day18;  \
	dotnet run test.txt;

.PHONY: make_day20
make_day20:
	cd day20;  \
	deno run --allow-read main.ts;

.PHONY: make_day21
make_day21:
	cd day21;  \
	./day21.sh test.txt;