# CHILL S3 SITE MAKER

This builds all the boiler-plate code for a site that will be deployed to
AWS S3. It provides a webpack configuration to bundle Javscript, as well.

## Requirements
* AWS CLI Tools
* NodeJS 8 or higher
* A ~/.aws/credentials file properly configured

## Install & Run
* Copy the bash script to your working directory. The script will make your
  projects in this directory.

* Full installation command below if working from home directory  
* `cd chill-s3-site-maker && cp makeS3Site.sh ~/makeS3Site.sh && chmod +x makeS3Site.sh && cd .. && echo "SUCCESS - Chill Site Maker Installed!!!"`

* Run the script and answer all the questions
* `sh makeS3Site.sh` or `./makeS3Site.sh`

  * Questions will require you know what your aws profile in your aws credentials are.

  * Questions will also require that you know the name of the bucket you want to
   upload your site to.

  * Once your project is created, read the README created for your project. 
