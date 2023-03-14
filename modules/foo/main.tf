data "google_storage_bucket" "foo" {
  name = "mizzy-270104.appspot.com"
}


data "archive_file" "archive" {
  type = "zip"
  source_dir  = "${path.module}/../foo/source"
  output_path = "${path.module}/foo.zip"
}

resource "google_storage_bucket_object" "object" {
  name   = "foo-${data.archive_file.archive.output_md5}.zip"
  bucket = data.google_storage_bucket.foo.name
  source = data.archive_file.archive.output_path
}
