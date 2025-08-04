resource "aws_s3_bucket" "my-s3-bucket" {
    bucket = var.bucket
    tags = {
        Name = "${var.project}-s3"
        env = var.env
    } 
    force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "s3-website" {
    bucket = aws_s3_bucket.my-s3-bucket.id
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "error.html"
    }
}

resource "aws_s3_bucket_policy" "s3-bucket-policy" {
    bucket = aws_s3_bucket.my-s3-bucket.id
    policy = data.aws_iam_policy_document.s3-iam-policy.json
    depends_on = [ aws_s3_bucket_public_access_block.public_block ]

  
}

data "aws_iam_policy_document" "s3-iam-policy" {
    
    statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.my-s3-bucket.arn}/*"
    ]
  }
  
}

# resource "aws_s3_object" "index" {
#     bucket = aws_s3_bucket.my-s3-bucket.id
#     key = "index.html"
#     source = "./website/index.html"
#     content_type = "text/html"
#     etag = filemd5("./website/index.html")
    

  
# }
# resource "aws_s3_object" "error" {
#     bucket = aws_s3_bucket.my-s3-bucket.id
#     key = "error.html"
#     source = "./website/error.html"
#     content_type = "text/html"
#     etag = filemd5("./website/error.html")
    
  
# }
resource "null_resource" "upload_website" {
  provisioner "local-exec" {
    command = "aws s3 sync ./website/barista_cafe s3://${aws_s3_bucket.my-s3-bucket.bucket} --acl public-read"
  }

  depends_on = [
    aws_s3_bucket.my-s3-bucket,
    aws_s3_bucket_policy.s3-bucket-policy
  ]
}

resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.my-s3-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_owner_control" {
  bucket = aws_s3_bucket.my-s3-bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "s3-bucket-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_owner_control,
    aws_s3_bucket_public_access_block.public_block,
  ]

  bucket = aws_s3_bucket.my-s3-bucket.id
  acl    = "public-read"
}
