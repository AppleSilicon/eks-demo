# Bucket creation
resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "s3-demo"

  tags = {
    Name       = "Demo s3 bucket"
    Enviroment = "Dev"
  }
}