#!/bin/bash

rm -rf toc-trade-protobuf
git clone git@github.com:ToC-Taiwan/toc-trade-protobuf.git

rm -rf lib/pb
mkdir lib/pb

protoc \
    --dart_out=./lib/pb \
    --proto_path=./toc-trade-protobuf/protos/v3/app  \
    ./toc-trade-protobuf/protos/v3/app/app.proto

rm -rf toc-trade-protobuf
git add lib/pb
