all: make_day1 make_day2

.PHONY: make_day1
make_day1:
	echo "\n\n#### day 1\n"
	cd day1; \
	npm i;   \
	npm start;
  
.PHONY: make_day2
make_day2:
	echo "\n\n#### day 2\n"
	cd day2/aoc-2022-day2;                                                               \
	mvn package;                                                                         \
	java -cp target/aoc-2022-day2-1.0-SNAPSHOT.jar com.pessimistic.App;   
