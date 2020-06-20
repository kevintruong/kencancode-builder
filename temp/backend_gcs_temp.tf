terraform {
  backend "gcs" {
    bucket = "kencancode"
    prefix = "$TF_PROJECT_PREFIX"
    credentials = "kencancode-builder.json"
  }
}