resource "google_identity_platform_config" "auth" {
  provider                   = google-beta
  project                    = google_project.default.project_id
  autodelete_anonymous_users = false

  sign_in {
    allow_duplicate_emails = false

    anonymous {
      enabled = true
    }

    email {
      enabled           = false
      password_required = false
    }

    phone_number {
      enabled            = false
      test_phone_numbers = {}
    }
  }

  multi_tenant {
    allow_tenants = false
  }

  depends_on = [
    google_project_service.default,
  ]
}
