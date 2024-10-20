set -e
validate-daemon

export ENV="development"
export BRANCH=$bamboo_planRepository_branch
export TAG=$bamboo_build_version
export COMPOSE_FILE=${1-docker-compose.ui.tests.yml}
export ARTIFACTS_DIRECTORY="./.artifacts"
export SITECORE_NPM_REGISTRY="https://npm.sitecore.com/internal_prod/"
export SITECORE_NPM_TOKEN=$bamboo_cloudsmith_password_readwrite
export DOMAIN="sitecore-staging.cloud"
export ENV_SUFFIX="dev"
export DEPLOY_ENV=${bamboo_deployment_environmentName:-"unknown"}
export BUILD_NUMBER=${bamboo_buildNumber}

export AZURE_STORAGE_ACCOUNT_NAME=${bamboo_azure_blob_storage_account_name}
export AZURE_STORAGE_ACCOUNT_KEY=${bamboo_azure_blob_storage_account_secret}
export AZURE_STORAGE_TABLE_NAME=${bamboo_azure_storage_table_name}
export AZURE_STORAGE_TABLE_URL=${bamboo_azure_storage_table_url}

BAMBOO_TIMESTAMP=${bamboo_buildTimeStamp}
BAMBOO_TIMESTAMP_SPLIT=(${BAMBOO_TIMESTAMP//:/ })
export BUILD_TIMESTAMP=${BAMBOO_TIMESTAMP_SPLIT[0]}:${BAMBOO_TIMESTAMP_SPLIT[1]}

echo "$bamboo_mregistry_password_readwrite" | docker login $bamboo_docker_registry --username "$bamboo_mregistry_username_readwrite" --password-stdin

echo "Bamboo docker namespace: $bamboo_docker_namespace"
ARRAY=(${bamboo_docker_namespace//// })
export PREFIX=${ARRAY[0]}/${ARRAY[1]}
echo $PREFIX

# Intermediate images used for build
export MONOREPO_IMAGE_TAG=$bamboo_docker_registry/$PREFIX/components/components-monorepo:${BRANCH-latest}-cache
export E2E_IMAGE_TAG=$bamboo_docker_registry/$PREFIX/components/components-e2e:${BRANCH-latest}-cache
export K6_IMAGE_TAG=$bamboo_docker_registry/$PREFIX/components/components-k6:${BRANCH-latest}-cache

# Images used for kubelets
export FRONTEND_IMAGE_TAG=$bamboo_docker_registry/$PREFIX/components/components:${TAG-dev}
export BACKEND_IMAGE_TAG=$bamboo_docker_registry/$PREFIX/components-api/components-api:${TAG-dev}

if [ $BRANCH == "main" ]; then
  ENV="production"
elif [ $BRANCH == "staging" ] || [ $BRANCH == "qa" ] || [ $BRANCH == "pre-production" ]; then
  ENV=$BRANCH
fi

if [ $DEPLOY_ENV == "PRODUCTION" ]; then
  ENV_SUFFIX=""
  DOMAIN="sitecorecloud.io"
elif [ $DEPLOY_ENV == "Staging" ]; then
  ENV_SUFFIX="staging"
elif [ $DEPLOY_ENV == "QA" ]; then
  ENV_SUFFIX="qa"
elif [ $DEPLOY_ENV == "Pre-Production" ]; then
  ENV_SUFFIX="beta"
  DOMAIN="sitecorecloud.io"
fi

echo "BRANCH: $BRANCH"
echo "ENV: $ENV"
echo "ENV_SUFFIX: $ENV_SUFFIX"
echo "DOMAIN: $DOMAIN"
