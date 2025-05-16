variable "google_billing_account_id" {
  type        = string
  description = "Google Cloudの請求先アカウントID"
}

variable "google_project_location" {
  type        = string
  description = "Google Cloudプロジェクトのロケーション"
}

variable "ios_app_team_id" {
  type        = string
  description = "Apple開発者アカウントのチームID"
}

variable "firebase_android_app_sha1_hashes" {
  type        = list(string)
  description = "AndroidアプリのSHA-1ハッシュリスト"
}
