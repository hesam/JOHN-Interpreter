#! /bin/sh
DIR=/Users/hesam/Desktop/Research/tools/Kodkod/kodkodi-1.1.4
java -cp $DIR/jar/kodkodi-1.1.4.jar:$DIR/jar/antlr-runtime-3.1.1.jar:$DIR/../kodkod.jar -Djava.library.path=$DIR/../x86-mac de/tum/in/isabelle/Kodkodi/Kodkodi < $1

