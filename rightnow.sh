#!/usr/bin/env bash

echo "Hey."
echo "What are you listening to right now ? "
read now

cd ~/rightnow/
source ~rightnow/env/activate
rightnow=`python ~/rightnow/rightnow.py "$now"`

message="Right now: $rightnow"

git add index.html
git commit -m "${message}"
git push

echo "OK."
