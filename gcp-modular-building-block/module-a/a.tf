resource "google_storage_bucket_object" "empty_folder" {
  name   = "empty_folder/" # folder name should end with '/'
  content = " "            # content is ignored but should be non-empty
  bucket = var.bucket_name
}