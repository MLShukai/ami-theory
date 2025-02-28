#!/bin/bash

for file in docs/*.typ; do
  if [[ $(basename "$file") != _* ]]; then
    typst compile "$file" "dist/$(basename "$file" .typ).pdf"
  fi
done
