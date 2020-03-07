#!/bin/bash
# build, test and push docker images

set -euo pipefail

if [ "${TRAVIS_BRANCH}" = master ]; then
  IMAGE_TAG=latest
else
  IMAGE_TAG="${TRAVIS_BRANCH}"
fi
export IMAGE_TAG

get_version () {
  echo -e '\n<<< Getting & setting versioning info >>>\n'
  SEMVER_BUMP="${SEMVER_BUMP}"
  if CURRENT_VERSION=$(docker run --rm "${IMAGE_NAME}":"${IMAGE_TAG}" cat VERSION 2> /dev/null); then
    echo "${CURRENT_VERSION}" > VERSION
  fi
  # allows for starting semantic versioning & overriding auto-calculated value (set within TravisCI)
  if [[ -n "${SEMVER_OVERRIDE}" ]]; then
    echo "${SEMVER_OVERRIDE}" > VERSION
  fi
  NEXT_VERSION=$(docker run --rm -it -v "${PWD}":/app -w /app treeder/bump --filename VERSION "${SEMVER_BUMP}")
  echo "Version: ${NEXT_VERSION}"
  export NEXT_VERSION
}

build_images () {
  echo -e '\n<<< Building default image >>>\n'
  docker build --rm -f Dockerfile -t "${IMAGE_NAME}":"${IMAGE_TAG}" .
  for DISTRO in $(find . -type f -iname "Dockerfile.*" -print | cut -d'/' -f2 | cut -d'.' -f 2); do
    echo -e "\n<<< Building ${DISTRO} image >>>\n"
    docker build --rm -f Dockerfile."${DISTRO}" -t "${IMAGE_NAME}":"${DISTRO}"-"${IMAGE_TAG}" .
  done
  echo -e '\n<<< Cleaning up dangling images >>>\n'
  docker rmi "$(docker images -f dangling=true -q)" 2>&-
}

install_prereqs () {
  echo -e '\n<<< Installing (d)goss & trivy prerequisites >>>\n'
  # goss/dgoss (server-spec for containers)
  GOSS_VER=$(curl -s "https://api.github.com/repos/aelsabbahy/goss/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  export GOSS_VER
  curl -sL "https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VER}/goss-linux-amd64" -o "${HOME}/bin/goss"
  curl -sL "https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VER}/dgoss" -o "$HOME/bin/dgoss"
  # trivy (vuln scanner)
  TRIVY_VER=$(curl -s "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  export TRIVY_VER
  wget -q "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VER}/trivy_${TRIVY_VER}_Linux-64bit.tar.gz"
  tar -C "${HOME}/bin" -zxf "trivy_${TRIVY_VER}_Linux-64bit.tar.gz" trivy
  # snyk (vuln scanner)
  SNYK_VER=$(curl -s "https://api.github.com/repos/snyk/snyk/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  export SNYK_VER
  curl -sL "https://github.com/snyk/snyk/releases/download/v$SNYK_VER/snyk-linux" -o "$HOME/bin/snyk"
  chmod +rx "$HOME"/bin/{goss,dgoss,snyk}
}

vulnerability_scanner () {
  echo -e '\n<<< Checking image for vulnerabilities >>>\n'
  trivy --clear-cache
  #trivy --exit-code 0 --severity "UNKNOWN,LOW,MEDIUM,HIGH" --no-progress "${IMAGE_NAME}":"${IMAGE_TAG}"
  #trivy --exit-code 1 --severity CRITICAL --no-progress "${IMAGE_NAME}":"${IMAGE_TAG}"
  #if [[ "${TRAVIS_BRANCH}" = master ]]; then
  #  snyk auth "${SNYK_TOKEN}" &> /dev/null
  #  snyk monitor --docker "${IMAGE_NAME}":"${IMAGE_TAG}" --file=Dockerfile
  #fi
  for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
    trivy --exit-code 0 --severity "UNKNOWN,LOW,MEDIUM,HIGH" --no-progress "${IMAGE}"
    trivy --exit-code 1 --severity CRITICAL --no-progress "${IMAGE}"
    if [[ "${TRAVIS_BRANCH}" = master ]]; then
      snyk auth "${SNYK_TOKEN}" &> /dev/null
      snyk monitor --docker "${IMAGE}" --file=Dockerfile
    fi
  done
}

test_images () {
  echo -e '\n<<< Testing default image >>>\n'
  export GOSS_SLEEP=5
  #dgoss run -e PUID=1000 -e PGID=1000 "${IMAGE_NAME}":"${IMAGE_TAG}"
  for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
    dgoss run -e PUID=1000 -e PGID=1000 -v "${PWD}":/docs "${IMAGE}"
  done
}

push_images () {
  echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin &> /dev/null
  echo -e '\n<<< Pushing default image >>>\n'
  docker tag "${IMAGE_NAME}":"${IMAGE_TAG}" "${IMAGE_NAME}":"${NEXT_VERSION}"
  #docker push "${IMAGE_NAME}":"${IMAGE_TAG}"
  #docker push "${IMAGE_NAME}":"${NEXT_VERSION}"
  for DISTRO in $(find . -type f -iname "Dockerfile.*" -print | cut -d'/' -f2 | cut -d'.' -f 2); do
    docker tag "${IMAGE_NAME}":"${DISTRO}"-"${IMAGE_TAG}" "${IMAGE_NAME}":"${DISTRO}"-"${NEXT_VERSION}"
  #  docker push "${IMAGE_NAME}":"${DISTRO}"-"${IMAGE_TAG}"
  #  docker push "${IMAGE_NAME}":"${DISTRO}"-"${NEXT_VERSION}"
  done
  for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
    docker push "${IMAGE}"
  done
}

get_version
build_images
install_prereqs
if [[ "${VULNERABILITY_TEST}" = true ]]; then
  vulnerability_scanner
fi
test_images
if [[ "${TRAVIS_PULL_REQUEST}" = false ]] && [[ "${TRAVIS_BRANCH}" =~ ^(dev|master)$ ]]; then
  push_images
fi
