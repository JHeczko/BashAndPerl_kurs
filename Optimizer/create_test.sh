#!/bin/bash

echo "========= Tworze testy ========="
rm -rf test img_test

mkdir -p ./test/{a,b,c}/{d,e,f}/{g,h,i} && find ./test -type d | while read dir; do for f in plik1.txt plik2.txt plik3.txt; do [ $((RANDOM % 2)) -eq 0 ] && case $f in plik1.txt) echo "zawartosc1" > "$dir/$f";; plik2.txt) echo "zawartosc2" > "$dir/$f";; plik3.txt) echo "zawartosc3" > "$dir/$f";; esac; done; done

cp -r DIR01 ./img_test
echo "========= Skonczylem ========="