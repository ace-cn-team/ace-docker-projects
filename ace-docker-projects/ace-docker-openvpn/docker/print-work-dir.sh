#!/bin/bash
param_script_abs=${1}
script_abs=${param_script_abs:=$(readlink -f "$0")}
echo "param_script_abs:${param_script_abs}"
echo "script_abs:${param_script_abs}"