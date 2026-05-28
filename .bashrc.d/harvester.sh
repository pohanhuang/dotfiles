build_harvester() {
  local tag="${1:-latest}"

  export REPO=pohanhuangtw
  export USE_LOCAL_IMAGES=true
  export TAG="$tag"

  echo "Building Harvester with TAG: $TAG"
  echo ""

  make package || return 1

  echo ""
  echo "Pushing images..."
  docker push ${REPO}/harvester:${TAG}
  echo "✓ Done!"
}

alias bh="build_harvester "

build_harvester_webhook() {
  local tag="${1:-latest}"

  export REPO=pohanhuangtw
  export USE_LOCAL_IMAGES=true
  export TAG="$tag"

  echo "Building webhook with TAG: $TAG"
  echo ""

  make package-harvester-webhook || return 1

  echo ""
  echo "Pushing image..."
  docker push ${REPO}/harvester-webhook:${TAG}
  echo "✓ Done!"
}

alias bhw="build_harvester_webhook "