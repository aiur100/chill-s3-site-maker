#!/bin/bash

LOG_PREFIX="[CHILL-S3-SITE-MAKER] >> "
echo "$LOG_PREFIX Enter project name: "
read PROJECT_NAME

echo "$LOG_PREFIX Enter project description: "
read PROJECT_DESCRIPTION

echo "$LOG_PREFIX Enter AWS Profile to use in ~/.aws/credentials: "
read AWS_PROFILE

echo "$LOG_PREFIX Enter AWS Bucket Name where site will persist: "
read S3_BUCKET

echo "$LOG_PREFIX Creating S3 site for \"$PROJECT_NAME\"..."

mkdir $PROJECT_NAME && cd $PROJECT_NAME && mkdir dist && mkdir src && mkdir api_src
touch package.json index.html webpack.config.js webpack.config.prod.js src/main.js

echo "alert('hello world');" > src/main.js

cd api_src

serverless create --template aws-nodejs

cd ..

README_TEXT=$(cat << EOF

# $PROJECT_NAME

$PROJECT_DESCRIPTION

This site is intended to be distributed and hosted on an S3 bucket.

## Production Deployment Dependencies

* In order to deploy this to Amazon S3, you'll need a \`.aws/credentials\` profile
named \`$AWS_PROFILE\`. 

* You will need the \`aws cli\` application installed.

* You will need the **serverless framework** installed.

* The profile \`$AWS_PROFILE\` will have a AWS secret and key that will
allow the aws CLI functions to work.

## Important Directories
* \`./src\` - Contains uncompiled JS code.  All development done here.
* \`./dist\` - Contains compiled JS code and should not be altered.
* \`./api_src\` - Contains the server side code that must be managed, and deployed separately. The commands below do not deploy or manage this code.

# Local Development
### Getting Ready...
* Run \`npm install\` to have all dependencies installed
* Run \`http-server\` in CLI and open http://127.0.0.1:8080 in your browser.  You'll
see the page.
### Once you're Ready...
* JS code must be compiled using webpack.
* Use \`npm run-script build\` to build for local development. _This will launch webpack in listening mode,
  so your changes will appear at the local address_

## Releasing to Production
* To deploy code to production S3 bucket hosting, run \`npm run-script release\`

EOF
)
touch README.md
echo "${README_TEXT}" > README.md

PACKAGE_JSON=$(cat <<EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "$PROJECT_DESCRIPTION",
  "main": "./dist/main.js",
  "dependencies": {
  },
  "devDependencies": {
    "webpack": "^4.27.1",
    "webpack-cli": "^3.1.2",
    "http-server": "^0.11.1"
  },
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack --config webpack.config.js --watch --info-verbosity verbose",
    "release": "webpack --config webpack.config.prod.js && aws s3 sync . s3://$S3_BUCKET --acl=public-read --cache-control 'max-age=0'  --delete --exclude=\".idea/*\" --exclude=\"src/*\" --exclude=README.md --exclude=\"node_modules/*\"  --exclude=\"api_src/*\" --exclude=\"webpack.config.js\" --exclude=\"webpack.config.prod.js\" --exclude=\"*.json\" --exclude=\"*.gitignore*\" --exclude=\".git/*\" --profile $AWS_PROFILE && echo \"Release complete!!\""
  },
  "author": "Christopher R. Hill",
  "license": "ISC"
}
EOF
)

echo "${PACKAGE_JSON}" > package.json

BOILER_HTML=$(cat <<EOF
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>$PROJECT_NAME</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    </head>
    <body>
        <div class="container-fluid">

            <div class="row d-flex sticky-top justify-content-center">

                <div class="card">

                    <div class="card-header">
                      <h1>$PROJECT_NAME</h1>
                    </div>

                    <div class="card-body">
                        <img src="https://avatars2.githubusercontent.com/u/3620834?s=460&v=4" alt="Chill Site" />
                    </div>

                </div>

            </div>

        </div>
        <script src="main.js"></script>
    </body>
</html>
EOF
)

echo "${BOILER_HTML}" > index.html


WEBPACK_DEV=$(cat <<EOF
const path = require('path');

module.exports = {
  entry: './src/main.js',
  mode: 'development',
  output: {
    filename: 'main.js',
    path: path.resolve(__dirname, './dist')
  }
};
EOF
)

echo "${WEBPACK_DEV}" > webpack.config.js

WEBPACK_PROD=$(cat <<EOF

const path = require('path');

module.exports = {
    entry: './src/main.js',
    mode: 'production',
    output: {
        filename: 'main.js',
        path: path.resolve(__dirname, './dist')
    }
};

EOF
)

echo "${WEBPACK_PROD}" > webpack.config.prod.js

npm install

echo "$LOG_PREFIX Your project is complete!"
