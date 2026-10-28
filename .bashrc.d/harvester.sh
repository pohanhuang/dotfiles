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

harvester_build_local_iso() (
  set -euo pipefail

  local top_dir="${HARVESTER_DIR:-$(git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null || echo /home/po/suse/harvester/harvester)}"
  local skip_package=false
  local image_name image
  local missing_images=0
  local required_images=(harvester harvester-webhook harvester-upgrade)

  case "${1:-}" in
  "")
    ;;
  --skip-package)
    skip_package=true
    ;;
  *)
    echo "Usage: harvester_build_local_iso [--skip-package]" >&2
    return 2
    ;;
  esac

  if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is unavailable." >&2
    return 1
  fi

  if [[ ! -f "${top_dir}/Makefile" ]]; then
    echo "ERROR: Harvester checkout not found: ${top_dir}" >&2
    return 1
  fi

  cd "${top_dir}"

  if [[ "${skip_package}" == false ]]; then
    make package-all
  fi

  make gen-version-env >/dev/null
  source "${top_dir}/scripts/.version_env"

  echo "Checking local images in ${REPO} with tag ${IMAGE_PUSH_TAG}"
  for image_name in "${required_images[@]}"; do
    image="${REPO}/${image_name}:${IMAGE_PUSH_TAG}"

    if docker image inspect "${image}" >/dev/null 2>&1; then
      echo "  found: ${image}"
    else
      echo "  missing: ${image}" >&2
      missing_images=1
    fi
  done

  if [[ "${missing_images}" -ne 0 ]]; then
    echo "ERROR: required local images are missing." >&2
    echo "Run without --skip-package to build them." >&2
    return 1
  fi

  USE_LOCAL_IMAGES="${IMAGE_PUSH_TAG}" make build-iso
)

alias bhi="harvester_build_local_iso "
alias bhis="harvester_build_local_iso --skip-package"
