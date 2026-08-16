#! /bin/bash
df -h | grep -E '^/dev/' | awk '{printf "%sX%sX%sX%sX%sX%s", $1, $2, $3, $4, $5, $6}'
anyamtyukja
apamtyukja