default: format check build run

format:
    roc format src/main.roc

check:
    roc check src/main.roc

build:
    mkdir -p bin
    roc build --output=bin/fortune --optimize src/main.roc

run:
    bin/fortune
