#!/bin/bash

# Generates a JAR of .java files for the .jj files.

JAVACC="$1"
EXPRESSION_PARSER_JJ="$2"
SOY_FILE_PARSER_JJ="$3"
TEMPLATE_PARSER_JJ="$4"
OUTPUT_FILE="$5"

cd $TMP

mkdir -p com/google/template/soy/exprparse
java -classpath $JAVACC org.javacc.parser.Main $EXPRESSION_PARSER_JJ
mv *.java com/google/template/soy/exprparse

mkdir -p com/google/template/soy/soyparse
java -classpath $JAVACC org.javacc.parser.Main $SOY_FILE_PARSER_JJ
mv *.java com/google/template/soy/soyparse

mkdir -p com/google/template/soy/soyparse
java -classpath $JAVACC org.javacc.parser.Main $TEMPLATE_PARSER_JJ
mv *.java com/google/template/soy/soyparse

tar cf $OUTPUT_FILE *
