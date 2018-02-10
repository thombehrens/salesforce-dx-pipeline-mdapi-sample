#################################################################
# Script to setup a fully configured pipeline for Salesforce DX #
#################################################################

# Create a unique var to append
TICKS=$(echo $(date +%s | cut -b1-13))

# Declare values
HEROKU_TEAM_NAME="appcloud-dev"
HEROKU_STAGING_APP_NAME="staging$TICKS"
HEROKU_PROD_APP_NAME="prod$TICKS"
HEROKU_PIPELINE_NAME="pipeline$TICKS"
GITHUB_REPO="wadewegner/salesforce-dx-pipeline-sample"

# Create Heroku apps
heroku apps:create $HEROKU_STAGING_APP_NAME -t $HEROKU_TEAM_NAME
heroku apps:create $HEROKU_PROD_APP_NAME -t $HEROKU_TEAM_NAME

# Set config vars for Dev Hub in Staging
# These values are used by review apps
heroku config:set DEV_HUB_CLIENT_ID=blah -a $HEROKU_STAGING_APP_NAME
heroku config:set DEV_HUB_USERNAME=blah -a $HEROKU_STAGING_APP_NAME
heroku config:set DEV_HUB_CERT_KEY=blah -a $HEROKU_STAGING_APP_NAME

# Set config vars for Staging and Prod
heroku config:set USERNAME=blah -a $HEROKU_STAGING_APP_NAME
heroku config:set USERNAME=blah -a $HEROKU_PROD_APP_NAME

heroku config:set STAGE=STAGING -a $HEROKU_STAGING_APP_NAME
heroku config:set STAGE=PROD -a $HEROKU_PROD_APP_NAME

# Add buildpacks to apps
heroku buildpacks:add -i 1 https://github.com/wadewegner/salesforce-cli-buildpack -a $HEROKU_STAGING_APP_NAME
heroku buildpacks:add -i 1 https://github.com/wadewegner/salesforce-cli-buildpack -a $HEROKU_PROD_APP_NAME
heroku buildpacks:add -i 2 https://github.com/wadewegner/salesforce-dx-buildpack -a $HEROKU_STAGING_APP_NAME
heroku buildpacks:add -i 2 https://github.com/wadewegner/salesforce-dx-buildpack -a $HEROKU_PROD_APP_NAME

# Create Pipeline
heroku pipelines:create $HEROKU_PIPELINE_NAME -a $HEROKU_STAGING_APP_NAME -s staging -t $HEROKU_TEAM_NAME
heroku pipelines:add $HEROKU_PIPELINE_NAME -a $HEROKU_PROD_APP_NAME -s production
# bug: https://github.com/heroku/heroku-pipelines/issues/80
# heroku pipelines:setup $HEROKU_PIPELINE_NAME $GITHUB_REPO -y -t $HEROKU_TEAM_NAME

# Clean up script
echo "heroku pipelines:destroy $HEROKU_PIPELINE_NAME
heroku apps:destroy -a $HEROKU_STAGING_APP_NAME -c $HEROKU_STAGING_APP_NAME
heroku apps:destroy -a $HEROKU_PROD_APP_NAME -c $HEROKU_PROD_APP_NAME" > destroy.sh

# 
echo ""
echo "Run ./destroy.sh to remove resources"
echo ""