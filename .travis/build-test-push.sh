#!/bin/bash
# build, test and push docker images

set -euo pipefail
set -xv
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
    docker build --rm -f Dockerfile."${DISTRO}" -t "${IMAGE_NAME}":"${IMAGE_TAG}"-"${DISTRO}" .
  done
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
  for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
    trivy --exit-code 0 --severity "UNKNOWN,LOW,MEDIUM,HIGH" --light -q "${IMAGE}"
    echo -e '\n<<< Critical Vulnerabilities >>>\n'
    trivy --exit-code 1 --severity CRITICAL --light -q "${IMAGE}"
    if [[ "${TRAVIS_BRANCH}" = master ]]; then
      snyk auth "${SNYK_TOKEN}" &> /dev/null
      snyk monitor --docker "${IMAGE_NAME}":"${IMAGE_TAG}" --file=Dockerfile
      for DISTRO in $(find . -type f -iname "Dockerfile.*" -print | cut -d'/' -f2 | cut -d'.' -f 2); do
        snyk monitor --docker "${IMAGE_NAME}":"${IMAGE_TAG}"-"${DISTRO}" --file=Dockerfile."${DISTRO}"
      done
    fi
  done
}

test_images () {
  for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
    echo -e "\n<<< Testing ${IMAGE} image >>>\n"
    dgoss run -e PUID=1000 -e PGID=1000 -v "${PWD}":/docs "${IMAGE}" serve -a 127.0.0.1:8000
  done
}

push_images () {
  echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin &> /dev/null
  if [[ "${TRAVIS_BRANCH}" = dev ]]; then
    for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
      echo -e "\n<<< Pushing ${IMAGE} image >>>\n"
      docker push "${IMAGE}"
    done
  elif [[ "${TRAVIS_BRANCH}" = master ]]; then
    docker tag "${IMAGE_NAME}":"${IMAGE_TAG}" "${IMAGE_NAME}":"${NEXT_VERSION}"
    for DISTRO in $(find . -type f -iname "Dockerfile.*" -print | cut -d'/' -f2 | cut -d'.' -f 2); do
      docker tag "${IMAGE_NAME}":"${IMAGE_TAG}"-"${DISTRO}" "${IMAGE_NAME}":"${NEXT_VERSION}"-"${DISTRO}"
    done
    for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
      echo -e "\n<<< Pushing ${IMAGE} image >>>\n"
      docker push "${IMAGE}"
    done  
  fi
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
