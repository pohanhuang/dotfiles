build_controller_image() {
  local tag="${1:-latest}"
  make build-controller-image REPO=pohanhuangtw TAG="$tag" &&
    docker push "pohanhuangtw/controller:$tag"
}
alias bci=build_controller_image

build_scanner_image() {
  local tag="${1:-latest}"
  cd /home/po/suse/nv/scanner || return 1

  docker buildx create --name neuvector --platform linux/amd64,linux/arm64,linux/s390x,linux/riscv64 2>/dev/null || true
  docker buildx use neuvector

  local commit=$(git rev-parse --short HEAD)
  local db_sha=$(sha256sum data/cvedb.regular | awk '{print $1}')
  local version="v4.109"

  docker buildx build -f package/Dockerfile \
    --builder neuvector \
    --build-arg VERSION="$version" \
    --build-arg COMMIT="$commit" \
    --build-arg VULNDB_VERSION="$tag" \
    --build-arg VULNDB_CHECKSUM="$db_sha" \
    -t "pohanhuangtw/scanner:$tag" \
    --load \
    . &&
    docker push "docker.io/pohanhuangtw/scanner:$tag"

  cd - >/dev/null
}
alias bsi=build_scanner_image

build_registry_adapter_image() {
  local tag="${1:-latest}"
  local repo="${2:-pohanhuangtw}"
  cd /home/po/suse/nv/registry-adapter || return 1

  docker buildx create --name neuvector --platform linux/amd64,linux/arm64,linux/s390x,linux/riscv64 2>/dev/null || true
  docker buildx use neuvector

  local commit dirty version git_tag
  commit=$(git rev-parse --short HEAD) || return 1

  if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    dirty="-dirty"
  fi

  git_tag=$(git tag -l --contains HEAD | head -n 1)
  if [[ -n "$git_tag" && -z "$dirty" ]]; then
    version="$git_tag"
  else
    version="${commit}${dirty}"
  fi

  docker buildx build -f package/Dockerfile \
    --builder neuvector \
    --build-arg VERSION="$version" \
    --build-arg COMMIT="$commit" \
    -t "${repo}/registry-adapter:$tag" \
    --load \
    . &&
    docker push "docker.io/${repo}/registry-adapter:$tag"

  cd - >/dev/null
}
alias brai=build_registry_adapter_image

