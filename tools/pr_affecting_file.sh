#!/bin/bash

curl -s https://api.github.com/repos/lnbook/lnbook/pulls | jq '.[]|.number' | while read pr; do
  git fetch --quiet github refs/pull/$pr/head
  if git show --pretty=format:'' --name-only FETCH_HEAD | grep -q $1; then
    echo "PR $pr"
  fi
done
