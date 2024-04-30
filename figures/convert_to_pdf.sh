#!/bin/bash

# sudo apt install librsvg2-bin
for file in *svg; do rsvg-convert -f pdf -o ${file%.*}.pdf $file; done
