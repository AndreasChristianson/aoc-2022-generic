all: make_day1 make_day2 make_day1_gps make_day3 make_day4 make_day5 make_day6 make_day7

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
	cd day7;                                                         \
	mvn package;                                                     \
	kotlin -cp target/day7-1.0-SNAPSHOT.jar com.pessimistic.HelloKt;