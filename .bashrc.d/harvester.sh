build_harvester() {
  local tag="${1:-latest}"

  export REPO=pohanhuangtw/harvester
  export PUSH=true
  export USE_LOCAL_IMAGES=true
  export TAG="$tag"

  echo "Building Harvester with:"
  echo "  REPO: $REPO"
  echo "  TAG: $TAG"
  echo "  PUSH: $PUSH"
  echo ""

  make
}

alias bh="build_harvester "
