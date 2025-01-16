#! /bin/bash
socat TCP-LISTEN:5556,fork,reuseaddr TCP:localhost:5555 &
