#terraform {
#  backend "gcs" {  # Use Google Cloud Storage as backend
#    bucket = "terraform101-tfstate"  # Replace with your bucket name
#    prefix = "main" # Replace with your folder inside bucket
#  }
#}

# create minimal backend config, the bucket name is passed 
# using the -backend-config in makefile as name is dynamic
terraform {
  backend "gcs" {
    prefix = "main"
  }
}
