#!/bin/bash

sed '/^$/d' /Users/josdmyer/list > output.txt

while true; read line; do open "$line"; done < output.txt

rm output.txt 
rm /Users/josdmyer/list
