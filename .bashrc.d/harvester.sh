build_harvester() {
  local tag="${1:-latest}"

  export REPO=pohanhuangtw
  unset PUSH=false
  export USE_LOCAL_IMAGES=true
  export TAG="$tag"

  echo "Building Harvester with TAG: $TAG"
  echo ""

  make || return 1

  echo ""
  echo "Pushing images..."
  docker push ${REPO}/harvester:${TAG}
  echo "✓ Done!"
}

alias bh="build_harvester "
