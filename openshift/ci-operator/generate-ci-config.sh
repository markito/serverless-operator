#!/bin/bash

branch=${1-'openshift-serverless-v1.0.0'}

cat <<EOF
tag_specification:
  name: '4.1'
  namespace: ocp
promotion:
  cluster: https://api.ci.openshift.org
  namespace: openshift
  name: $branch
base_images:
  base:
    name: '4.1'
    namespace: ocp
    tag: base
build_root:
  project_image:
    dockerfile_path: openshift/ci-operator/build-image/Dockerfile
binary_build_commands: make install
tests:
- as: e2e-aws
  commands: "make test-e2e"
  openshift_installer_src:
    cluster_profile: aws
resources:
  '*':
    limits:
      memory: 4Gi
    requests:
      cpu: 100m
      memory: 200Mi
images:
EOF

cat <<EOF
- dockerfile_path: build/Dockerfile
  from: base
  inputs:
    bin:
      paths:
      - destination_dir: .
        source_path: /go/src/github.com/openshift-knative/serverless-operator/olm-catalog
  to: serverless-operator
EOF
