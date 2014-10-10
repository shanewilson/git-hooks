# usage
# ./release.sh (release|retract) $COMMIT_SHA $NEXT_VERSION

# readJsonProp(jsonFile, property)
# - restriction: property needs to be on a single line!
function readJsonProp {
  echo $(sed -En 's/.*"'$2'"[ ]*:[ ]*"(.*)".*/\1/p' $1)
}

# replaceInFile(file, findPattern, replacePattern)
function replaceInFile {
  sed -i .tmp -E "s/$2/$3/" $1
  rm $1.tmp
}

# replaceJsonProp(jsonFile, propertyRegex, valueRegex, replacePattern)
# - note: propertyRegex will be automatically placed into a
#   capturing group! -> all other groups start at index 2!
function replaceJsonProp {
  replaceInFile $1 '"('$2')"[ ]*:[ ]*"'$3'"' '"\1": "'$4'"'
}

PACKAGE="package.json"
SNAPSHOT="-beta"

CURRENT_VERSION=$(readJsonProp ${PACKAGE} "version")

COMMIT_SHA=${2}
NEXT_VERSION="${3}" # should be semver, should be greater than current_version

# updates to release version
RELEASE_VERSION=${CURRENT_VERSION//${SNAPSHOT}/}
replaceJsonProp ${PACKAGE} "version" ".*" ${RELEASE_VERSION}

# updates changelog
npm run changelog

# tag commit
git add CHANGELOG.md package.json
git commit -m "chore(release): Release ${RELEASE_VERSION}"
git tag -s ${RELEASE_VERSION} -m "chore(release): $RELEASE_VERSION" "$COMMIT_SHA"

# updates to next development version
replaceJsonProp ${PACKAGE} "version" ".*" ${NEXT_VERSION}${SNAPSHOT}

# commit new version to master
git add package.json
git commit -m "chore(release): Start Development on ${NEXT_VERSION}"

# push master and tags
git push origin master && git push origin $RELEASE_VERSION