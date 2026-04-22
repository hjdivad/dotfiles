#!/usr/bin/env bash

#MISE description="run nvim tests"

cd packages/nvim && nvim -l tests/minit.lua --minitest
