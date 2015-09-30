#!/bin/bash

for word in $(ps | grep " .*$1")
do
    kill $word
    exit 0
done

