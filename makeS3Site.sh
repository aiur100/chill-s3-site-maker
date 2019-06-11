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

mkdir $PROJECT_NAME && cd $PROJECT_NAME && mkdir dist && mkdir src
touch package.json index.html webpack.config.js webpack.config.prod.js src/main.js

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
    "release": "webpack --config webpack.config.prod.js && aws s3 sync . s3://$S3_BUCKET --acl=public-read --cache-control 'max-age=0'  --delete --exclude=\".idea/*\" --exclude=\"src/*\" --exclude=README.md --exclude=\"node_modules/*\"  --exclude=\"webpack.config.js\" --exclude=\"webpack.config.prod.js\" --exclude=\"*.json\" --exclude=\"*.gitignore*\" --exclude=\".git/*\" --profile $AWS_PROFILE && echo \"Release complete!!\""
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
        <link href="https://fonts.googleapis.com/css?family=Raleway&display=swap" rel="stylesheet">
        <style>
            html, body { font-family: 'Raleway', sans-serif; margin: 0; }
            a { color: #FF9900; }
            h1 { font-weight: 300; }
            .app { width: 100%; }
            .app-header { color: white; text-align: center; background: linear-gradient(30deg, #f90 55%, #FFC300); width: 100%; margin: 0 0 1em 0; padding: 3em 0 3em 0; box-shadow: 1px 2px 4px rgba(0, 0, 0, .3); }
            .app-logo { width: 126px; margin: 0 auto; }
            .app-body { width: 400px; margin: 0 auto; text-align: center; }
            .app-body button { background-color: #33DDFF; font-size: 14px; color: white; text-transform: uppercase; padding: 1em; border: none; }
            .app-body button:hover { opacity: 0.8; }
        </style>
    </head>
    <body>
        <div class="app">
            <div class="app-header">
                <div class="app-logo">
                    <img src="https://avatars2.githubusercontent.com/u/3620834?s=460&v=4" alt="Chill Site" />
                </div>
                <h1>$PROJECT_NAME</h1>
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

echo "$LOG_PREFIX Your project is complete! Dropping you in the directory..."

cd $PROJECT_NAME
