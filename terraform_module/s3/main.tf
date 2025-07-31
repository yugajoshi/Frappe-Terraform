resource "aws_s3_bucket" "my-s3-bucket" {
    bucket = var.bucket
    tags = {
        Name = "${var.project}-s3"
        env = var.env
    } 
}
