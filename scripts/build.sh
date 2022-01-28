#!/usr/bin/env bash

# Builds the project for release.
#
# A new folder is generated from the project's source code where all .spec
# and .story files are pruned

OUTPUT_NAME="ComplexRegions"
OUTPUT_EXT="rbxmx"
INPUT_DIR="src"
OUTPUT_DIR="build"
EXCLUDES=(
	"*.spec.lua"
)

OUTPUT_MODEL="$OUTPUT_NAME.$OUTPUT_EXT"
PROJECT_FILE_SOURCE="{
  \"name\": \"$OUTPUT_NAME\",
  \"tree\": {
    \"\$path\": \"../$OUTPUT_DIR\"
  }
}"
PROJECT_FILE=$(dirname $0)/build.project.json

if [ -d $OUTPUT_DIR ]; then
  echo "[info] Cleaning existing '$OUTPUT_DIR' dir..."
  rm -rf $OUTPUT_DIR
fi

echo "[info] Copying '$INPUT_DIR' to '$OUTPUT_DIR'..."
cp -R $INPUT_DIR $OUTPUT_DIR

echo "[info] Pruning excluded files from '$OUTPUT_DIR'..."
for pattern in ${EXCLUDES[*]}; do
	find $OUTPUT_DIR -name "$pattern" -type f -delete -print
done

echo "[info] Building with Rojo to '$OUTPUT_MODEL'..."
echo $PROJECT_FILE_SOURCE >> $PROJECT_FILE
rojo build $PROJECT_FILE -o $OUTPUT_MODEL
rm $PROJECT_FILE
