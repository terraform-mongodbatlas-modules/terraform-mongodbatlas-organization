provider "mongodbatlas" {}

provider "mongodbatlas" {
  alias       = "child_org"
  public_key  = module.atlas_org.public_key
  private_key = module.atlas_org.private_key
}
