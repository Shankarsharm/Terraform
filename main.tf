terraform {
    backend "s3" {
        bucket = "shanakr-tfbucket"
        region = "ap-south-1"
        key = "terraform-state"
    }
}